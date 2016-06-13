FROM debian:jessie

ENV DEBIAN_FRONTEND noninteractive

# installer components
ENV INSTALLER_VERSION 1.0

RUN dpkg --add-architecture i386
RUN sed -i "s/main/main contrib non-free/" etc/apt/sources.list

RUN apt-get update && apt-get install -yq wine python curl unrar unzip

# setup innosetup
RUN mkdir innosetup && \
    cd innosetup && \
    curl -fsSL -o innounp045.rar "https://downloads.sourceforge.net/project/innounp/innounp/innounp%200.45/innounp045.rar?r=&ts=1439566551&use_mirror=skylineservers" && \
    unrar e innounp045.rar

RUN cd innosetup && \
    curl -fsSL -o is-unicode.exe http://files.jrsoftware.org/is/5/isetup-5.5.8-unicode.exe && \
    wine "./innounp.exe" -e "is-unicode.exe"

# setup Windows python + py2exe
# note: Pythons < 3.5 use MSI installers, while Python 3.5+ uses an exe
# installer which can be run as ./python.exe /quiet PrependPath=1
# however py2exe does not work on Python 3.5 yet
ENV PYTHON_VERSION 3.4.4
RUN mkdir python && \
  cd python && \
  curl -fsSL -o python.msi "https://www.python.org/ftp/python/${PYTHON_VERSION}/python-${PYTHON_VERSION}.msi" && \
  wine "msiexe /qn python.msi" && \
  wine setx \M PATH "%PATH%;C:\Python\Python34;C:\Python\Python34\Scripts" && \
  wine pip install pypiwin32 py2exe

RUN wine python setup.py build py2exe

#RUN rm -rf /tmp/.wine-0/
#RUN wine ../innosetup/ISCC.exe Toolbox.iss /DMyAppVersion=$INSTALLER_VERSION
CMD bash
