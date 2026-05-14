# Extension identification
EXTENSION = pg_projection
EXTVERSION = 1.0

# Files to be installed
DATA = $(wildcard *--*.sql)
DOCS = $(wildcard *.md)

# Test variables (uncomment and adjust if creating tests with pg_regress)
# TESTS = $(wildcard test/sql/*.sql)
# REGRESS = $(patsubst test/sql/%.sql,%,$(TESTS))
# REGRESS_OPTS = --inputdir=test

# PGXS configuration
PG_CONFIG ?= pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

# Utility target for creating the zip file for PGXN (requires Git)
dist:
	git archive --format zip --prefix=$(EXTENSION)-$(EXTVERSION)/ -o $(EXTENSION)-$(EXTVERSION).zip HEAD
