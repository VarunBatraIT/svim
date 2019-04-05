FROM ubuntu:18.04

WORKDIR /tmp


# User config
ENV UID="1000" \
    UNAME="developer" \
    GID="1000" \
    GNAME="developer" \
    SHELL="/bin/bash" \
    UHOME=/home/developer
ENV GOROOT="/usr/lib/go"
ENV GOBIN="$GOROOT/bin"
ENV GOPATH="$UHOME/workspace"
ENV PATH="$PATH:$GOBIN:$GOPATH/bin"
ENV TZ=Asia/Kolkata
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

 # NOTE: man page is ignored
RUN echo "deb mirror://mirrors.ubuntu.com/mirrors.txt bionic main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb mirror://mirrors.ubuntu.com/mirrors.txt bionic-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb mirror://mirrors.ubuntu.com/mirrors.txt bionic-security main restricted universe multiverse" >> /etc/apt/sources.list && \
    DEBIAN_FRONTEND=noninteractive apt-get update
RUN apt-get install vim vim-nox  -y

# User
# Create HOME dir
RUN mkdir -p "${UHOME}" \
    && chown "${UID}":"${GID}" "${UHOME}" \
# Create user
    && echo "${UNAME}:x:${UID}:${GID}:${UNAME},,,:${UHOME}:${SHELL}" \
    >> /etc/passwd \
    && echo "${UNAME}::17032:0:99999:7:::" \
    >> /etc/shadow \
# No password sudo
    && echo "${UNAME} ALL=(ALL) NOPASSWD: ALL" \
    > "/etc/sudoers.d" \
    && chmod 0440 "/etc/sudoers.d" \
# Create group
    && echo "${GNAME}:x:${GID}:${UNAME}" \
    >> /etc/group
RUN apt-get install -y curl openssh-client  diffutils bash ctags curl git python python3 golang cmake llvm perl python-dev autoconf  automake  gcc g++ clang make
# Install Pathogen
RUN mkdir -p \
    $UHOME/bundle \
    $UHOME/.vim/autoload \
    $UHOME/.vim_runtime/temp_dirs \
    && curl -LSso \
    $UHOME/.vim/autoload/pathogen.vim \
    https://tpo.pe/pathogen.vim \
#custom .vimrc stub
    && mkdir -p /ext  && echo " " > /ext/.vimrc
# Vim plugins deps
# YouCompleteMe
# Install PHP
RUN apt-get install -y php php-json php-phar php-mbstring php-iconv php-pdo php-tokenizer php-curl php-dom php-xml php-xmlwriter \
    && php -r "copy('https://getcomposer.org/download/1.8.4/composer.phar', 'composer.phar');" \
    && php -r "if (hash_file('sha256', 'composer.phar') === '1722826c8fbeaf2d6cdd31c9c9af38694d6383a0f2bf476fe6bbd30939de058a') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer.phar'); } echo PHP_EOL;" \
    && chmod +x composer.phar \
    && mv composer.phar /usr/local/bin/composer \
# Install Node
    && apt-get install -y nodejs npm \
# Install Node Related
    && npm -g install typescript tslint eslint prettier \
    && npm cache clean --force

RUN git clone --depth 1 https://github.com/Shougo/vimproc.vim \
    $UHOME/bundle/vimproc.vim \
    && cd $UHOME/bundle/vimproc.vim \
    && make \
    && chown $UID:$GID -R $UHOME \
    && chown $UNAME:root -R /usr/lib/go/


USER $UNAME

RUN git clone --depth=1 https://github.com/amix/vimrc.git $UHOME/.vim_runtime_x \
    && cp -r $UHOME/.vim_runtime_x/* $UHOME/.vim_runtime/ \
	&& sh $UHOME/.vim_runtime/install_awesome_vimrc.sh \
# Plugins
    && cd $UHOME/.vim_runtime/sources_non_forked \
    && rm -rf bufexplorer && git clone --depth 1 https://github.com/jlanzarotta/bufexplorer \
    && rm -rf ctrlp.vim && git clone --depth 1 https://github.com/kien/ctrlp.vim \
    && rm -rf delimitMate && git clone --depth 1 https://github.com/Raimondi/delimitMate \
    && rm -rf Dockerfile.vim && git clone --depth 1 https://github.com/ekalinin/Dockerfile.vim \
    && rm -rf EasyGrep && git clone --depth 1 https://github.com/vim-scripts/EasyGrep \
    && rm -rf FlyGrep.vim && git clone --depth 1 https://github.com/wsdjeg/FlyGrep.vim.git \
    && rm -rf html5.vim && git clone --depth 1 https://github.com/othree/html5.vim \
    && rm -rf mru.vim && git clone --depth 1 https://github.com/vim-scripts/mru.vim \
    && rm -rf nedtree-git-plugin && git clone --depth 1 https://github.com/xuyuanp/nerdtree-git-plugin.git \
    && rm -rf nerdcommenter && git clone --depth 1 https://github.com/scrooloose/nerdcommenter \
    && rm -rf nerdtree && git clone --depth 1 https://github.com/scrooloose/nerdtree \
    && rm -rf syntastic && git clone --depth 1 https://github.com/scrooloose/syntastic \
    && rm -rf tabular && git clone --depth 1 https://github.com/godlygeek/tabular \
    && rm -rf tagbar && git clone --depth 1 https://github.com/majutsushi/tagbar \
    && rm -rf taglist.vim && git clone --depth 1 https://github.com/vim-scripts/taglist.vim \
    && rm -rf tlib-vim && git clone --depth 1 https://github.com/tomtom/tlib_vim \
    && rm -rf typescript-vim && git clone --depth 1 https://github.com/leafgarland/typescript-vim.git \
    && rm -rf ultisnips && git clone --depth 1 https://github.com/SirVer/ultisnips \
    && rm -rf undotree && git clone --depth 1 https://github.com/mbbill/undotree \
    && rm -rf vim-abolish && git clone --depth 1 https://github.com/tpope/vim-abolish \
    && rm -rf vim-addon-mw-utils && git clone --depth 1 https://github.com/marcweber/vim-addon-mw-utils \
    && rm -rf vim-airline && git clone --depth 1 https://github.com/bling/vim-airline \
    && rm -rf vim-better-whitespace && git clone --depth 1 https://github.com/ntpeters/vim-better-whitespace.git \
    && rm -rf vim-bookmarks && git clone --depth 1 https://github.com/MattesGroeger/vim-bookmarks.git \
    && rm -rf vim-easymotion && git clone --depth 1 https://github.com/easymotion/vim-easymotion \
    && rm -rf vim-expand-region && git clone --depth 1 https://github.com/terryma/vim-expand-region \
    && rm -rf vim-fugitive && git clone --depth 1 https://github.com/tpope/vim-fugitive \
    && rm -rf vim-gitgutter && git clone --depth 1 https://github.com/airblade/vim-gitgutter \
    && rm -rf vim-go && git clone --depth 1 https://github.com/fatih/vim-go \
    && rm -rf vim-haml && git clone --depth 1 https://github.com/tpope/vim-haml \
    && rm -rf vim-highlight-cursor-words && git clone --depth 1 https://github.com/pboettch/vim-highlight-cursor-words.git \
    && rm -rf vim-indent-guides && git clone --depth 1 https://github.com/nathanaelkane/vim-indent-guides \
    && rm -rf vim-indent-object && git clone --depth 1 https://github.com/michaeljsmith/vim-indent-object \
    && rm -rf vim-javascript && git clone --depth 1 https://github.com/pangloss/vim-javascript \
    && rm -rf vim-json && git clone --depth 1 https://github.com/elzr/vim-json \
    && rm -rf vim-jsx && git clone --depth 1 https://github.com/mxw/vim-jsx \
    && rm -rf vim-less && git clone --depth 1 https://github.com/groenewege/vim-less \
    && rm -rf vim-markdown && git clone --depth 1 https://github.com/plasticboy/vim-markdown \
    && rm -rf vim-multiple-cursors && git clone --depth 1 https://github.com/terryma/vim-multiple-cursors \
    && rm -rf vim-nertree-tabs && git clone --depth 1 https://github.com/jistr/vim-nerdtree-tabs \
    && rm -rf vim-repeat && git clone --depth 1 https://github.com/tpope/vim-repeat \
    && rm -rf vim-scala -rf && git clone --depth 1 https://github.com/derekwyatt/vim-scala \
    && rm -rf vim-snippets && git clone --depth 1 https://github.com/honza/vim-snippets \
    && rm -rf vim-surround && git clone --depth 1 https://github.com/tpope/vim-surround \
    && rm -rf vim-tmux-navigator && git clone --depth 1 https://github.com/christoomey/vim-tmux-navigator \
    && rm -rf YankRing.vim && git clone --depth 1 https://github.com/vim-scripts/YankRing.vim \
    && rm -rf tsuquyomi && git clone --depth 1 https://github.com/Quramy/tsuquyomi.git \
    && rm -rf vimproc && git clone --depth 1 https://github.com/Shougo/vimproc.vim.git \
    && rm -rf unite.vim && git clone --depth 1 https://github.com/Shougo/unite.vim.git \
    && rm -rf phpactor && git clone --depth 1 https://github.com/phpactor/phpactor.git \
    && rm -rf vim-colors-solarized && git clone --depth 1 https://github.com/altercation/vim-colors-solarized \
    && rm -rf vim-pythonx && git clone --depth 1 https://github.com/reconquest/vim-pythonx \
    && rm -rf deoplete.nvim && git clone --depth 1 https://github.com/Shougo/deoplete.nvim \
    && rm -rf nvim-yarp && git clone --depth 1 https://github.com/roxma/nvim-yarp \
    && rm -rf vim-hug-neovim-rpc && git clone --depth 1 https://github.com/roxma/vim-hug-neovim-rpc \
# Further for PHP
    && cd $UHOME/.vim_runtime/sources_non_forked && cd phpactor && composer install \
# Further for Typescript
    && cd $UHOME/.vim_runtime/sources_non_forked \
    && cd $UHOME/.vim_runtime/sources_non_forked/vimproc.vim \
    && make \
    # Go requirements
    && go get -v -u -d github.com/klauspost/asmfmt/cmd/asmfmt \
    && go build -o $GOBIN/asmfmt github.com/klauspost/asmfmt/cmd/asmfmt \
    && go get -v -u -d github.com/go-delve/delve/cmd/dlv \
    && go build -o $GOBIN/dlv github.com/go-delve/delve/cmd/dlv \
    && go get -v -u -d github.com/kisielk/errcheck \
    && go build -o $GOBIN/errcheck github.com/kisielk/errcheck \
    && go get -v -u -d github.com/davidrjenni/reftools/cmd/fillstruct \
    && go build -o $GOBIN/fillstruct github.com/davidrjenni/reftools/cmd/fillstruct \
RUN go get -v -u -d github.com/stamblerre/gocode \
    && go build -o $GOBIN/gocode-gomod github.com/stamblerre/gocode \
    && cp $GOBIN/gocode-gomod $GOBIN/gocode \
RUN go get -v -u -d github.com/rogpeppe/godef \
    && go build -o $GOBIN/godef github.com/rogpeppe/godef \
    && go get -v -u -d github.com/zmb3/gogetdoc \
    && go build -o $GOBIN/gogetdoc github.com/zmb3/gogetdoc \
    && go get -v -u -d golang.org/x/tools/cmd/goimports \
    && go build -o $GOBIN/goimports golang.org/x/tools/cmd/goimports \
    && go get -v -u -d golang.org/x/lint/golint \
    && go build -o $GOBIN/golint golang.org/x/lint/golint \
    && go get -v -u -d golang.org/x/tools/cmd/gopls \
    && go build -o $GOBIN/gopls golang.org/x/tools/cmd/gopls \
    && go get -v -u -d github.com/alecthomas/gometalinter \
    && go build -o $GOBIN/gometalinter github.com/alecthomas/gometalinter \
    && go get -v -u -d github.com/fatih/gomodifytags \
    && go build -o $GOBIN/gomodifytags github.com/fatih/gomodifytags \
    && go get -v -u -d golang.org/x/tools/cmd/gorename \
    && go build -o $GOBIN/gorename golang.org/x/tools/cmd/gorename \
    && go get -v -u -d github.com/jstemmer/gotags \
    && go build -o $GOBIN/gotags github.com/jstemmer/gotags \
    && go get -v -u -d golang.org/x/tools/cmd/guru \
    && go build -o $GOBIN/guru golang.org/x/tools/cmd/guru \
    && go get -v -u -d github.com/josharian/impl \
    && go build -o $GOBIN/impl github.com/josharian/impl \
    && go get -v -u -d honnef.co/go/tools/cmd/keyify \
    && go build -o $GOBIN/keyify honnef.co/go/tools/cmd/keyify \
    && go get -v -u -d github.com/fatih/motion \
    && go build -o $GOBIN/motion github.com/fatih/motion \
    && go get -v -u -d github.com/koron/iferr \
    && go build -o $GOBIN/iferr github.com/koron/iferr \
    && echo "bind -r '\C-s'" >> $UHOME/.bashrc \
    && echo "tty -ixon" >> $UHOME/.bashrc

# Pathogen help tags generation
RUN vim -E -c 'execute pathogen#helptags()' -c q ; return 0
# More plugins

USER root
RUN cd $UHOME && rm -rf $GOPATH/src/ &&  rm -rf ./.vim_runtime_x/ && rm -rf $UHOME/.composer/cache/ && cd $UHOME && find . | grep "\.git/" | xargs rm -rf && rm -rf /var/cache/* && rm -rf /tmp/ && mkdir /tmp/ && rm -rf $UHOME/.vim_runtime_x/
RUN chmod 1777 /tmp
RUN apt-get install python3-pip -y
RUN pip3 install pynvim
RUN pip3 install neovim
RUN pip3 install --user pynvim
RUN pip3 install --user neovim
USER $UNAME
COPY .vimrc $UHOME/my.vimrc
# Build default .vimrc

RUN rm -rf $UHOME/.vim_runtime/sources_non_forked/vim-pythonx


RUN mv -f $UHOME/.vimrc $UHOME/.vimrc~ \
    && cat  $UHOME/my.vimrc >> $UHOME/.vimrc~ \
    && sed -i '/colorscheme peaksea/d' $UHOME/.vimrc~ \
    && echo "set backspace=indent,eol,start" >> $UHOME/.vimrc~ \
    && echo "execute pathogen#infect('$UHOME/bundle/{}')" \
    > $UHOME/.vimrc \
    && echo "syntax on " \
    >> $UHOME/.vimrc \
    && echo "filetype plugin indent on " \
    && echo "" \
    >> $UHOME/.vimrc

# List of Vim plugins to disable
ENV DISABLE=""
ENV TERM=xterm-256color
# Vim wrapper
COPY run /usr/local/bin/

ENV GOPATH="$UHOME/workspace;$UHOME/workspace/src"

ENTRYPOINT ["sh", "/usr/local/bin/run"]
