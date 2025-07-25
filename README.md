# 🚀 OpenCode AI Development Stack

**Author:** Jason Hempstead <casjay@yahoo.com>  
**License:** MIT  
**Platform:** Arch Linux, Manjaro, EndeavourOS (Arch-based distributions)

A fully automated, zero-interaction shell script that installs and configures an entire AI development stack using only user-space binaries, Docker containers, and XDG-compliant paths.

## 🎯 What This Installs

All AI tools and interfaces are installed and configured to work together seamlessly:

- **🤖 OpenCode AI** - AI-powered development environment
- **📦 Ollama** - Local LLM inference server
- **🌐 OpenWebUI** - Web interface for AI interactions
- **🎨 OpenDiffusion** - Stable Diffusion image generation
- **🗣️ Piper TTS** - Text-to-speech synthesis
- **⚡ Continue** - VSCode AI coding assistant extension

## 🚀 Quick Start

# Clone or download the installer
curl -O https://github.com/casapps/localia/raw/refs/heads/main/OpenCode.sh
chmod +x OpenCode.sh

# Run the installer (zero interaction required)
./OpenCode.sh

## 📋 Prerequisites

**Required:**

- Arch-based Linux distribution (Arch, Manjaro, EndeavourOS)
- curl for downloads
- docker for containers
- Internet connection for downloads

**Optional:**

- VSCode (for Continue extension)
- GPU drivers (NVIDIA/AMD for better performance)

## 🖥️ System Requirements

**Minimum:**

- 8GB RAM
- 20GB free disk space
- x86_64 architecture

**Recommended:**

- 16GB+ RAM
- 50GB+ free disk space
- Dedicated GPU (NVIDIA/AMD)
- SSD storage

## 🧠 Model Selection Logic

The installer automatically selects optimal models based on your hardware:

### Language Models (Ollama)

- **NVIDIA GPU:** codellama:13b-instruct (best coding performance)
- **AMD GPU:** llama2:13b (good general performance)
- **CPU Only:** llama2:7b (lightweight)

### Image Generation Models

- **NVIDIA GPU:** dreamshaper-v7 (high quality)
- **AMD GPU:** deliberate-v2 (balanced)
- **CPU Only:** dreamlike-diffusion-1.0 (fast)

### Text-to-Speech Models

- **NVIDIA GPU:** en-us-libritts-high.onnx (highest quality)
- **AMD GPU:** en-us-amy-high.onnx (good quality)
- **CPU Only:** en-us-amy-low.onnx (fast)
Here's the next chunk of README.md:

## 📁 Directory Structure

All components follow XDG Base Directory Specification:

~/.local/bin/
├── opencode          # OpenCode AI binary
├── ollama            # Ollama binary
└── piper             # Piper TTS binary

~/.local/share/
├── models/
│   ├── ollama/       # Language models
│   ├── images/       # Image generation models
│   └── tts/          # Text-to-speech models
└── openwebui/        # OpenWebUI data

~/.config/
└── opencode/
    └── config.json   # OpenCode configuration

## 🐳 Docker Containers

The installer creates and manages these containers:

| Service       | Port | Container Name | Image                                         |
| ------------- | ---- | -------------- | --------------------------------------------- |
| OpenWebUI     | 3000 | openwebui      | ghcr.io/open-webui/open-webui:main            |
| OpenDiffusion | 7860 | opendiffusion  | ghcr.io/casjaysdevdocker/opendiffusion:latest |

## 🎮 Usage

# Start all services
./manage.sh start

ollama serve &
docker start openwebui opendiffusion

### Using the Tools

# Launch OpenCode AI
opencode

# Access web interfaces
firefox http://localhost:3000  # OpenWebUI
firefox http://localhost:7860  # OpenDiffusion

# Test TTS
echo "Hello world" | piper --model ~/.local/share/models/tts/en-us-amy-low.onnx --output-file test.wav

### VSCode Integration

The Continue extension is automatically installed and configured to work with your local Ollama instance.

## 🔧 Configuration

### OpenCode AI Configuration

The installer generates ~/.config/opencode/config.json:

{
  "llm": {
    "provider": "openai",
    "api_key": "ollama-placeholder",
    "base_url": "http://localhost:11434/v1",
    "model": "llama2:7b"
  },
  "image_generator": {
    "provider": "sd",
    "base_url": "http://localhost:7860",
    "model": "dreamlike-diffusion-1.0"
  },
  "user": {
    "name": "Jason Hempstead",
    "email": "casjay@yahoo.com"
  },
  "telemetry": {
    "enabled": false
  }
}

### Environment Variables

# Add to ~/.bashrc for persistent PATH
export PATH="$HOME/.local/bin:$PATH"

# Ollama model directory
export OLLAMA_MODELS="$HOME/.local/share/models/ollama"
Here's the final chunk of README.md:

## 🧪 Testing Installation

# Run comprehensive tests
./manage.sh test

# Manual verification
opencode --version
ollama list
curl http://localhost:3000
curl http://localhost:7860
curl http://localhost:11434/api/tags

## 🔍 Troubleshooting

### Common Issues

**Docker Permission Denied:**
sudo usermod -aG docker $USER
newgrp docker

**Ollama Not Starting:**
# Check if port is in use
lsof -i :11434

# Restart manually
pkill ollama
ollama serve

**OpenWebUI Connection Issues:**
# Check container logs
docker logs openwebui -f

# Restart container
docker restart openwebui

**Models Not Loading:**
# Check model directory permissions
ls -la ~/.local/share/models/ollama

# Re-download models
ollama pull llama2:7b

### Log Locations

- **Ollama logs:** Check systemd journal or terminal output
- **Docker logs:** docker logs <container_name>
- **OpenCode logs:** ~/.config/opencode/logs/

## 🚀 Architecture Support

| Architecture    | Status          | Notes                            |
| --------------- | --------------- | -------------------------------- |
| x86_64 (amd64)  | ✅ Full Support  | Recommended                      |
| ARM64 (aarch64) | ⚠️ Limited       | Some models may not be available |
| ARMv7           | ❌ Not Supported | Insufficient resources           |

## 📊 Performance Expectations

### Language Model Inference Speed (tokens/second)

| Hardware            | llama2:7b | llama2:13b | codellama:13b |
| ------------------- | --------- | ---------- | ------------- |
| NVIDIA RTX 4090     | ~80       | ~45        | ~40           |
| NVIDIA RTX 3080     | ~60       | ~30        | ~25           |
| AMD RX 7900 XT      | ~45       | ~25        | ~20           |
| CPU Only (12 cores) | ~8        | ~4         | ~3            |

### Image Generation Times

| Hardware        | 512x512 | 1024x1024 |
| --------------- | ------- | --------- |
| NVIDIA RTX 4090 | ~3s     | ~8s       |
| NVIDIA RTX 3080 | ~5s     | ~15s      |
| AMD RX 7900 XT  | ~8s     | ~25s      |
| CPU Only        | ~120s   | ~400s     |

# Update only Docker images
docker pull ghcr.io/open-webui/open-webui:main
docker pull ghcr.io/casjaysdevdocker/opendiffusion:latest
./manage.sh stop
./manage.sh start

### Model Management

# List installed models
ollama list

# Remove unused models
ollama rm <model_name>

# Update models
ollama pull <model_name>

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Follow POSIX shell scripting standards
4. Test on multiple Arch-based distributions
5. Submit a pull request

## 📄 License

MIT License - see LICENSE file for details

## 🆘 Support

- **Issues:** GitHub Issues
- **Email:** casjay@yahoo.com
- **Documentation:** Check the troubleshooting section above

## 🙏 Acknowledgments

- OpenCode AI team for the amazing development environment
- Ollama for local LLM inference
- Open WebUI for the beautiful interface
- Piper TTS for speech synthesis
- Continue team for VSCode integration

---

**Happy coding with AI! 🚀🤖**
