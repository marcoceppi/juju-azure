PROJECT=jujuweb

PYHOME=.venv/bin
NOSE=$(PYHOME)/nosetests
FLAKE8=$(PYHOME)/flake8
PYTHON=$(PYHOME)/python


all: lint test

.PHONY: clean
clean:
	rm -rf MANIFEST dist/* $(PROJECT).egg-info .coverage
	find . -name '*.pyc' -delete
	rm -rf .venv

.PHONY: test
test: .venv
	@echo Starting tests...
	@$(NOSE) --with-coverage --cover-package $(PROJECT)

.PHONY: lint
lint: .venv
	@$(FLAKE8) $(PROJECT) --ignore E501 && echo OK

.venv: develop

$(PYTHON):
	sudo apt-get install -qy python-virtualenv
	virtualenv .venv

develop: $(PYTHON)
	$(PYTHON) setup.py develop
