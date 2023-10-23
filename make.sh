docker run -it -v $(pwd):/build jaczekanski/psn00bsdk:latest make $@ && ./mkpsxiso mkpsxiso.xml -y
