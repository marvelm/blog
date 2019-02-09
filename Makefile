build:
	hugo

dev:
	hugo server -D

publish: build
	(cd public && git commit -a -m 'Rebuild')

