# Meu setup melhor que o do Leo

esse é o setup do [Leo](https://github.com/levonhart/config)

# AstroNvim Template

**NOTE:** This is for AstroNvim v4+

A template for getting started with [AstroNvim](https://github.com/AstroNvim/AstroNvim)

## 😎 Dependencias
Segue o passo a passo de tudo que instalei na maquina:

### WSL configurações (depende da sua versao)
Acesse esse [link](https://learn.microsoft.com/pt-br/windows/wsl/setup/environment) para mais detalhes. (Por favor, leia)

### Na marra no powershell
baixar uma porrada de coisa com o cargo ai meu mano!

### No Linux
```shell
sudo apt update
sudo apt upgrade
```

## 🛠️ Installation

#### Make a backup of your current nvim and shared folder

```shell
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.local/state/nvim ~/.local/state/nvim.bak
mv ~/.cache/nvim ~/.cache/nvim.bak
```

#### Create a new user repository from this template

Press the "Use this template" button above to create a new repository to store your user configuration.

You can also just clone this repository directly if you do not want to track your user configuration in GitHub.

#### Clone the repository

Bash Zsh:

```shell
git clone https://github.com/caiosaboia/config ~/.config/nvim

#or ssh:
git clone git@github.com:caiosaboia/config.git ~/.config/nvim
```

powershell

```shell
git clone --depth 1 https://github.com/caiosaboia/config $env:LOCALAPPDATA\nvim
#so se quiser
#Remove-Item $env:LOCALAPPDATA\nvim\.git -Recurse -Force
nvim
```

#### Others

sioyek (PDF Reader ok?)

```shell
sudo apt install sioyek
```

#### Start Neovim

```shell
nvim
```


