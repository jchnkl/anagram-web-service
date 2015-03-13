FROM jotrk/haskell-base
MAINTAINER Jochen Keil

# for unix-compat
ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get install -y zlib1g-dev

RUN cabal update
# RUN cabal install 'unix-compat == 0.4.1.4'
RUN cabal install dlist text warp scotty aeson unordered-containers

# RUN useradd --system --shell /bin/nologin reddit
# RUN git clone http://github.com/reddit/reddit.git /reddit
# RUN chown -R reddit:reddit /reddit
#
# WORKDIR /reddit/r2
#
# USER reddit
# RUN python setup.py build
#
# USER root
# RUN python setup.py develop
#
# USER reddit
# RUN make
#
# ADD gs.update /reddit/r2/gs.update
# RUN make ini
#
# EXPOSE 8081
# ENTRYPOINT paster serve gs.ini http_port=8081
