VERSION ?= 0.0.1
NAME ?= hermantolim/puppeteer
GOOGLE_CHROME_CHANNEL ?= stable
BUILD_ARG = --build-arg=GOOGLE_CHROME_CHANNEL=$(GOOGLE_CHROME_CHANNEL)

.PHONY: all rel build_dev build_rel test tag

all: build_dev

rel: build_rel tag

build_dev:
	docker build --network=host -t $(NAME):$(VERSION) $(BUILD_ARG) .

build_rel:
	docker build --no-cache --rm --compress --network=host -t $(NAME):$(VERSION) $(BUILD_ARG) .

tag:
	docker tag $(NAME):$(VERSION) $(NAME):latest
