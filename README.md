# Run a (multimodal) LLM API server as a systemd user service

This is a small wrapper to build and run a llama.cpp llama-server
to serve a (multimodal) LLM.

## Installation

Clone the repository, build the llama-server and install a systemd user service:

```sh
git clone https://github.com/mlang/llm-api
make -C llm-api
```

The file `llm-api/Makefile` contains a `MODEL` variable at the top of the file.
It is preet to a model that should fit in 16GB RAM.
Change the `MODEL` variable if you want to use a different HuggingFace model.

To download the model and test the server, execute:

```sh
make -C llm-api llm-api
```

The LLM API will listen on 127.0.1.9:8080.

If this runs fine, you can start the systemd user service with:

```sh
systemctl --user start llm-api
```

### API client

If you are using the llm Python package, you can
copy the file `llm-api/extra-openai-models.yaml` to your llm config directory:

```sh
ln -s $(pwd)/llm-api/extra-openai-models.yaml ~/.config/io.datasette.llm/
```

## Usage

Assuming you are using the llm Python package, you can describe an image with:

```sh
llm -m local -a image.jpg
```

If this works, you can enable the llm-api service permanently with:

```sh
systemctl --user enable llm-api
```

This will start the llm-api service when you log in with the current user.
