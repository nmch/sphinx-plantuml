#For example
#docker run --rm -v `pwd`:/tmp/sphinx --name sphinx sphinx-plantuml sphinx-build -b html /tmp/sphinx/source /tmp/sphinx/build

FROM python:3.6-alpine

COPY requirements.txt .

RUN apk --no-cache add openjdk8-jre graphviz jpeg-dev zlib-dev ttf-dejavu freetype-dev git go && \
	apk --no-cache add npm && \
    apk --no-cache --virtual=dependencies add build-base python-dev py-pip wget

ENV LIBRARY_PATH=/lib:/usr/lib
#PlantUML
ENV PLANTUML_DIR /usr/local/plantuml
ENV PLANTUML_JAR plantuml.jar
ENV PLANTUML $PLANTUML_DIR/$PLANTUML_JAR

RUN \
    echo "#PlantUML" && \
    mkdir $PLANTUML_DIR && \
    wget "https://sourceforge.net/projects/plantuml/files/plantuml.jar" --no-check-certificate && \
    echo "#Check jar file size. refs #9. normal jar file size is maybe > 5mb" && \
    size=$(stat -c %s plantuml.jar) && \
    test $size -gt 5000000 && \
    mv plantuml.jar $PLANTUML_DIR && \
    echo "#TakaoFont for Japanese" && \
    wget "https://launchpad.net/takao-fonts/trunk/15.03/+download/TakaoFonts_00303.01.tar.xz" && \
    tar xvf TakaoFonts_00303.01.tar.xz -C /usr/share/fonts/ && \
    rm -f TakaoFonts_00303.01.tar.xz && \
    ln -s /usr/share/fonts/TakaoFonts_00303.01 /usr/share/fonts/TakaoFonts && \
    echo "#Upgrade pip" && \
    pip install --upgrade pip awscli && \
    echo "#Install Sphinx with Nice Theme&Extention" && \
    pip install -U -r requirements.txt && \
    echo "# for Build Infomation" && \
    pip freeze && \
    npm install -g --no-progress aglio --unsafe-perm && \
    go get -u github.com/achiku/planter && \
    mv /root/go/bin/planter /usr/local/bin && \
    apk del dependencies

# for sphinx-autobuild
EXPOSE 8000
# for aglio
EXPOSE 3000

CMD ["python3"]
