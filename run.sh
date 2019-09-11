# docker run --name dfemacs -it -u `id -u`:`id -g` -v $(pwd):/src dfemacs

docker run --name dfemacs -it -v $(pwd):/src dfemacs
docker rm dfemacs
