---
title: "Dynamically Scaling Kubernetes Deployments"
date: 2018-03-13T22:06:14-04:00
draft: true
---

- [Go client for Kubernetes](https://github.com/kubernetes/client-go)
- [Examples](https://github.com/kubernetes/client-go/tree/d6f3ab164c2f1710a3bb75f57f2306884492bd1b/examples)


```go
import (
    "time"

    metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
    "k8s.io/client-go/kubernetes"
    "k8s.io/client-go/kubernetes/typed/apps/v1beta2"
    autoscalingv1 "k8s.io/client-go/kubernetes/typed/autoscaling/v1"
    "k8s.io/client-go/rest"
    "k8s.io/client-go/util/retry"
)

var clientset *kubernetes.Clientset
var deploymentsClient v1beta2.DeploymentInterface

func kubeInit() {
  config, _ := rest.InClusterConfig()
  clientset, _ = kubernetes.NewForConfig(config)
  deploymentsClient = clientset.AppsV1beta2().Deployments(kubeNamespace)
}

func getNumWorkers() int {
  deployment, _ := deploymentsClient.Get("my-workers", metav1.GetOptions{})
  return int(*deployment.Spec.Replicas)
}

func setNumWorkers(numWorkers int) error {
  return retry.RetryOnConflict(retry.DefaultRetry, func() error {
    deployment, err := deploymentsClient.Get("my-workers", metav1.GetOptions{})
    if err != nil {
      return err
    }

    wrapper := int32(numWorkers)
    deployment.Spec.Replicas = &wrapper

    _, err = deploymentsClient.Update(deployment)
    return err
  })
}
```
