MODEL = ggml-org/pixtral-12b-GGUF
#MODEL = ggml-org/InternVL3-14B-Instruct-GGUF
#MODEL = ggml-org/SmolVLM2-2.2B-Instruct-GGUF
#MODEL = ggml-org/Mistral-Small-3.1-24B-Instruct-2503-GGUF
#MODEL = ggml-org/Qwen2.5-VL-7B-Instruct-GGUF
HOST = 127.0.1.9
PORT = 8080
THREADS = -1

PREFIX ?= $(shell pwd)
llama.cpp_CMAKEFLAGS += -DBUILD_SHARED_LIBS=Off
llama.cpp_CMAKEFLAGS += -DLLAMA_BUILD_EXAMPLES=Off
llama.cpp_CMAKEFLAGS += -DLLAMA_BUILD_TESTS=Off

#------------------------------------------------------------------------------#

CMAKEFLAGS += -DCMAKE_INSTALL_PREFIX=$(PREFIX)
CMAKEFLAGS += -DCMAKE_COLOR_MAKEFILE=OFF
ifneq ($(findstring s,$(filter-out --%,$(MAKEFLAGS))),)
CMAKEFLAGS += --log-level=WARNING
endif
CMAKE = cmake $(CMAKEFLAGS)

install: $(HOME)/.config/systemd/user/llm-api.service

$(HOME)/.config/systemd/user/llm-api.service: $(PREFIX)/bin/llama-server
	ln -s $(shell pwd)/llm-api.service $(HOME)/.config/systemd/user/
	systemctl --user daemon-reload

llm-api: $(PREFIX)/bin/llama-server
	$(PREFIX)/bin/llama-server --threads $(THREADS) -hf $(MODEL) --no-webui --host $(HOST) --port $(PORT)

.PHONY: llm-api

obj/%: src/%; mkdir -p $@

src/llama.cpp/CMakeLists.txt:
	git submodule update --init --recursive src/llama.cpp

obj/llama.cpp/Makefile: src/llama.cpp/CMakeLists.txt | obj/llama.cpp
	$(CMAKE) -S src/llama.cpp -B obj/llama.cpp $(llama.cpp_CMAKEFLAGS)

$(PREFIX)/bin/llama-server: obj/llama.cpp/Makefile
	$(MAKE) -C obj/llama.cpp install/strip
