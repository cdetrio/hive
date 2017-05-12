# Docker container spec for building the develop branch of pythereum.
FROM alpine:latest

RUN \
  apk add --update bash jq git curl python-dev musl-dev gcc make openssl-dev   \
                 g++ autoconf automake pkgconfig libtool libffi-dev gmp-dev && \
  curl -sSf https://bootstrap.pypa.io/get-pip.py -o get-pip.py              && \
  python get-pip.py                                                         && \
  ln -s /usr/bin/pip /bin/pip && \
  pip install pipenv && \
  mkdir pyeth && \
  cd pyeth && \
  pipenv --two && \
  pipenv install git+https://github.com/ethereum/serpent.git@develop#egg=ethereum-serpent && \
  pipenv install git+https://github.com/ethereum/pyethereum.git@2f8efd70771703142ea763d6d41d93a0fe2afc21#egg=ethereum && \
  pipenv install git+https://github.com/gsalgado/pyethapp.git@hive#egg=pyethapp && \
  #echo "{}"                                                                    \
  #    | jq ".+ {\"repo\":\"$(git config --get remote.origin.url)\"}"           \
  #    | jq ".+ {\"branch\":\"$(git rev-parse --abbrev-ref HEAD)\"}"            \
  #    | jq ".+ {\"commit\":\"$(git rev-parse HEAD)\"}"                         \
  #    > /version.json                                                       && \
  echo "{}" \
      | jq ". + {\"repo\":\"pipenv test\"}" \
      > /version.json && \
  apk del git make gcc g++ musl-dev curl pkgconfig libtool automake autoconf

# We can't delete /pyethapp--it's necessary for pyethapp to function.

# Inject the startup script
ADD pyethapp.sh /pyeth/pyethapp.sh
RUN chmod +x /pyeth/pyethapp.sh

# Add the config file

ADD config.yaml /root/.config/pyethapp/config.yaml

# Add the block import script

ADD importblock.py /pyeth/importblock.py
RUN chmod +x /pyeth/importblock.py

# Export the usual networking ports to allow outside access to the node
EXPOSE 8545 8546 30303

WORKDIR "/pyeth"
CMD ["/pyeth/pyethapp.sh"]
