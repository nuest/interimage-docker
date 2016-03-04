build:
	docker build -t interimage .

run:
	docker run -i -t -v /tmp/.X11-unix:/tmp/.X11-unix -e uid=$(id -u) -e gid=$(id -g) -e DISPLAY=unix$DISPLAY --name interimage interimage /bin/bash
