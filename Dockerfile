FROM jare/alpine-vim:latest

# User config
ENV UID="1000" \
    UNAME="developer" \
    GID="1000" \
    GNAME="developer" \
    SHELL="/bin/bash" \
    UHOME=/home/developer

# Used to configure YouCompleteMe
ENV GOROOT="/usr/lib/go"
ENV GOBIN="$GOROOT/bin"
ENV GOPATH="$UHOME/workspace"
ENV PATH="$PATH:$GOBIN:$GOPATH/bin"

# User
RUN apk --no-cache add sudo \
# Create HOME dir
    && mkdir -p "${UHOME}" \
    && chown "${UID}":"${GID}" "${UHOME}" \
# Create user
    && echo "${UNAME}:x:${UID}:${GID}:${UNAME},,,:${UHOME}:${SHELL}" \
    >> /etc/passwd \
    && echo "${UNAME}::17032:0:99999:7:::" \
    >> /etc/shadow \
# No password sudo
    && echo "${UNAME} ALL=(ALL) NOPASSWD: ALL" \
    > "/etc/sudoers.d/${UNAME}" \
    && chmod 0440 "/etc/sudoers.d/${UNAME}" \
# Create group
    && echo "${GNAME}:x:${GID}:${UNAME}" \
    >> /etc/group

# Install Pathogen
RUN apk --no-cache add curl \
    && mkdir -p \
    $UHOME/bundle \
    $UHOME/.vim/autoload \
    $UHOME/.vim_runtime/temp_dirs \
    && curl -LSso \
    $UHOME/.vim/autoload/pathogen.vim \
    https://tpo.pe/pathogen.vim \
    && echo "execute pathogen#infect('$UHOME/bundle/{}')" \
    > $UHOME/.vimrc \
    && echo "syntax on " \
    >> $UHOME/.vimrc \
    && echo "filetype plugin indent on " \
    >> $UHOME/.vimrc

#custom .vimrc stub
RUN mkdir -p /ext  && echo " " > /ext/.vimrc

# Vim plugins deps
RUN apk --update add \
    openssh-client \
    bash \
    ctags \
    curl \
    git \
    ncurses-terminfo \
    python \
# YouCompleteMe
    && apk add --virtual build-deps \
    build-base \
    cmake \
    go \
    llvm \
    perl \
    python-dev \
    && git clone --depth 1  https://github.com/Valloric/YouCompleteMe \
    $UHOME/bundle/YouCompleteMe/ \
    && cd $UHOME/bundle/YouCompleteMe \
    && git submodule update --init --recursive \
    && $UHOME/bundle/YouCompleteMe/install.py --gocode-completer \
# Install and compile procvim.vim
    && git clone --depth 1 https://github.com/Shougo/vimproc.vim \
    $UHOME/bundle/vimproc.vim \
    && cd $UHOME/bundle/vimproc.vim \
    && make \
    && chown $UID:$GID -R $UHOME \
# Cleanup
    && apk del build-deps \
    && apk add \
    libxt \
    libx11 \
    libstdc++ \
    && rm -rf \
    $UHOME/bundle/YouCompleteMe/third_party/ycmd/clang_includes \
    $UHOME/bundle/YouCompleteMe/third_party/ycmd/cpp \
    /usr/lib/go \
    /var/cache/* \
    /var/log/* \
    /var/tmp/* \
    && mkdir /var/cache/apk

USER $UNAME



COPY .vimrc $UHOME/my.vimrc


# Build default .vimrc
RUN  mv -f $UHOME/.vimrc $UHOME/.vimrc~ \
	 && git clone --depth=1 https://github.com/amix/vimrc.git $UHOME/.vim_runtime_x
RUN  cp -r $UHOME/.vim_runtime_x/* $UHOME/.vim_runtime/ \
	 && sh $UHOME/.vim_runtime/install_awesome_vimrc.sh \
     && cat  $UHOME/my.vimrc \
     >> $UHOME/.vimrc~ \
     # && rm $UHOME/my.vimrc \
     && sed -i '/colorscheme peaksea/d' $UHOME/.vimrc~

# Pathogen help tags generation
RUN vim -E -c 'execute pathogen#helptags()' -c q ; return 0

RUN echo "set backspace=indent,eol,start" >> $UHOME/.vimrc~

# Plugins
RUN cd $UHOME/.vim_runtime/sources_non_forked \
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
# Theme
    && rm -rf vim-colors-solarized && git clone --depth 1 https://github.com/altercation/vim-colors-solarized

# More plugins


RUN echo "bind -r '\C-s'" >> $UHOME/.bashrc
RUN echo "tty -ixon" >> $UHOME/.bashrc

ENV TERM=xterm-256color

# List of Vim plugins to disable
ENV DISABLE=""

# Vim wrapper
COPY run /usr/local/bin/

ENTRYPOINT ["sh", "/usr/local/bin/run"]
