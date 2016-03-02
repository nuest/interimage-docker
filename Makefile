build:
	docker build -t interimage .

run:
	docker run -i -t --name interimage interimage /bin/bash
