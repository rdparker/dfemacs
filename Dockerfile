# --- BUILDENV ----------------------------------------------------------------
FROM fsharp as buildenv
RUN sed -i '{p;s/^deb /deb-src /}' /etc/apt/sources.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get build-dep -y emacs25 && \
    apt-get install -y wget curl devscripts


# --- EMACS -------------------------------------------------------------------
FROM buildenv as build-emacs

COPY emacs-26.2.tar.xz .

RUN mkdir -p /opt && \
	tar x -C /opt -f emacs-26.2.tar.xz && \
	mv /opt/emacs-26.2 /opt/emacs && \
        cd /opt/emacs && \
	./autogen.sh && \
	mkdir /build && \
	cd /build && \
	/opt/emacs/configure --with-modules && \
	make -j 3 && \
	fakeroot bash -c "make install-arch-dep install-arch-indep prefix=/fakeroot" && \
	tar c -C /fakeroot -Jf emacs-26.2-debian-9.tar.xz .

# --- FSHARP .NET CORE 2.2.300 ------------------------------------------------
FROM fsharp as fsharp-netcore

ENV FrameworkPathOverride /usr/lib/mono/4.7.2-api/
ENV NUGET_XMLDOC_MODE skip
RUN apt-get update && \
    apt-get --no-install-recommends install -y \
    curl \
    libunwind8 \
    gettext \
    apt-transport-https \
    libc6 \
    libcurl3 \
    libgcc1 \
    libgssapi-krb5-2 \
    libicu57 \
    liblttng-ust0 \
    libssl1.0.2 \
    libstdc++6 \
    libunwind8 \
    libuuid1 \
    zlib1g && \
    rm -rf /var/lib/apt/lists/*
RUN DOTNET_SDK_VERSION=2.2.300 && \
    DOTNET_SDK_DOWNLOAD_URL=https://dotnetcli.blob.core.windows.net/dotnet/Sdk/$DOTNET_SDK_VERSION/dotnet-sdk-$DOTNET_SDK_VERSION-linux-x64.tar.gz && \
    DOTNET_SDK_DOWNLOAD_SHA=1d660a323180df3da8c6e0ea3f439d6bbec29670d498ac884f38bf3cdffbb041c7afff66171cdfd24c82394b845b135b057404def1fce9f206853726382bc42b && \
    curl -SL $DOTNET_SDK_DOWNLOAD_URL --output dotnet.tar.gz && \
    echo "$DOTNET_SDK_DOWNLOAD_SHA dotnet.tar.gz" | sha512sum -c - && \
    mkdir -p /usr/share/dotnet && \
    tar -zxf dotnet.tar.gz -C /usr/share/dotnet && \
    rm dotnet.tar.gz && \
    ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet
ENV DOTNET_CLI_TELEMETRY_OPTOUT 1
RUN mkdir warmup && \
    cd warmup && \
    dotnet new && \
    cd - && \
    rm -rf warmup /tmp/NuGetScratch
WORKDIR /root

# --- FSHARP 4.5 - .NET CORE 2.2.300 - EMACS 26.2  ----------------------------
from fsharp-netcore

ENV MONO_THREADS_PER_CPU 50
ENV LANG=en_US.utf-8

# install some additional dev tools desired or required
# we install vim-python-jedi instead of just vim to get python env required fsharp-vim plugin
RUN apt-get update -y && \
    apt-get --no-install-recommends install -yq apt-utils && \
    apt-get --no-install-recommends install -yq man less ctags wget curl git subversion ssh-client make unzip && \
    apt-get --no-install-recommends install -yq $(apt-cache depends emacs25 emacs25-bin emacs25-bin-common emacs25-common emacsen-common | awk '/Depends:/{print $2}' | grep -v emacs) && \
    apt-get clean

copy --from=build-emacs /opt /opt/
copy --from=build-emacs /fakeroot /usr/local/
# copy --from=build-omnisharp /opt /opt/

# set up dfemacs user with uid 1000 to (hopefully) match host uid
RUN useradd --shell /bin/bash -u 1000 -o -c "" -m dfemacs
copy .spacemacs /home/dfemacs/
RUN mkdir /src && \
    git clone https://github.com/syl20bnr/spacemacs ~dfemacs/.emacs.d && \
    chown dfemacs /home/dfemacs /src/ -R && \
    cd ~dfemacs && \
    ln -s /src . && \
    TERM=xterm su dfemacs -c 'script -qefc "emacs --eval \(save-buffers-kill-emacs\)" | cat -'

USER dfemacs
WORKDIR /home/dfemacs
CMD ["/bin/bash"]
