SRC_DIR := src
BUILD_DIR := build

# Find all .adoc files in SRC_DIR and its subdirectories
SRC_FILES := $(shell find $(SRC_DIR) -name '*.adoc')

# Replace SRC_DIR with BUILD_DIR and change extension to .html, .pdf, and -reveal.html
HTML_FILES := $(patsubst $(SRC_DIR)/%.adoc,$(BUILD_DIR)/%.html,$(SRC_FILES))
REVEAL_FILES := $(patsubst $(SRC_DIR)/%.adoc,$(BUILD_DIR)/%-reveal.html,$(SRC_FILES))
HANDOUT_FILES := $(patsubst $(SRC_DIR)/%.adoc,$(BUILD_DIR)/%-handout.html,$(SRC_FILES))
PDF_FILES := $(patsubst $(BUILD_DIR)/%.html,$(BUILD_DIR)/%.pdf,$(HTML_FILES) $(REVEAL_FILES) $(HANDOUT_FILES))

# Commands
ASCIIDOCTOR := asciidoctor
BUNDLE_EXEC := bundle exec
ASCIIDOCTOR_REVEALJS := $(BUNDLE_EXEC) asciidoctor-revealjs
HEADLESS_DRIVER := chromium

# Options
DIAGRAM_OPTION := -r asciidoctor-diagram
HANDOUT_OPTION := -a handout
WEBKIT_OPTIONS := --headless --disable-gpu --no-pdf-header-footer --print-to-pdf

# Default target
all: $(HTML_FILES) $(HANDOUT_FILES) $(REVEAL_FILES) $(PDF_FILES)

# Reveal.js target
handout: $(HANDOUT_FILES)

# Reveal.js target
reveal: $(REVEAL_FILES)

# Rule to create regular HTML documents
$(BUILD_DIR)/%.html: $(SRC_DIR)/%.adoc
	@mkdir -p $(dir $@)
	(set -x; $(ASCIIDOCTOR) $(DIAGRAM_OPTION) -o $@ $<) >>$@.log 2>&1

# Rule to create reveal.js presentations with diagrams using bundle exec
$(BUILD_DIR)/%-reveal.html: $(SRC_DIR)/%.adoc
	@mkdir -p $(dir $@)
	$(ASCIIDOCTOR_REVEALJS) $(DIAGRAM_OPTION) -a revealjsdir=https://cdn.jsdelivr.net/npm/reveal.js@5.1.0 -o $@ $<

# Rule to create handout HTML documents
$(BUILD_DIR)/%-handout.html: $(SRC_DIR)/%.adoc
	@mkdir -p $(dir $@)
	$(ASCIIDOCTOR) $(HANDOUT_OPTION) $(DIAGRAM_OPTION) -o $@ $<

# Rule to convert HTML to PDF using Google Chrome
$(BUILD_DIR)/%.pdf: $(BUILD_DIR)/%.html
	@mkdir -p $(dir $@)
	$(HEADLESS_DRIVER) $(WEBKIT_OPTIONS)=$@ $<

# Clean up the build directory
clean:
	rm -rf $(BUILD_DIR)

# Phony targets
.PHONY: all clean handout reveal
