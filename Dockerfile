FROM fsharp

ENV MONO_THREADS_PER_CPU 50

# install some additional dev tools desired or required
# we install vim-python-jedi instead of just vim to get python env required fsharp-vim plugin
RUN apt-get update -y && \
    apt-get --no-install-recommends install -yq apt-utils && \
    apt-get --no-install-recommends install -yq vim-python-jedi man less ctags wget curl git subversion ssh-client make unzip && \
    apt-get clean

# set up dfvim user with uid 1000 to (hopefully) match host uid
RUN useradd --shell /bin/bash -u 1000 -o -c "" -m dfvim
RUN mkdir /src && chown dfvim /src/ -R
USER dfvim

# set .bashrc and .vimrc (not .vimrc sets up fsharp-vim plugin using vim-plug system))
WORKDIR /home/dfvim
COPY .bashrc .
COPY .vimrc .

# install vim-plug and run setup 
RUN curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
RUN vim +PlugInstall +qall


WORKDIR /src
CMD ["/bin/bash"]
