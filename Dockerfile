ARG IMAGE=docker pull containers.intersystems.com/intersystems/iris-ml-community-arm64:latest-em
FROM $IMAGE 

WORKDIR /irisdev/app

## Python stuff
ENV IRISUSERNAME "SuperUser"
ENV IRISPASSWORD "SYS"
ENV IRISNAMESPACE "IRISAPP"
ENV ISC_PACKAGE_MGRUSER "irisowner"

ENV PYTHON_PATH=/usr/irissys/bin/
ENV LD_LIBRARY_PATH=${ISC_PACKAGE_INSTALLDIR}/bin:${LD_LIBRARY_PATH}

ENV PATH "/home/irisowner/.local/bin:/usr/irissys/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/irisowner/bin"
# RUN /bin/echo "User is : ${ISC_PACKAGE_MGRUSER}"
COPY . .

USER root

# Remove EXTERNAL-MANAGER from the system
RUN rm -f /usr/lib/python3.12/EXTERNALLY-MANAGED

# RUN mkdir /data \
# 	&& chown ${ISC_PACKAGE_MGRUSER} /data

	# Update package and install sudo
RUN apt-get update && apt-get install -y nano sudo 
RUN /bin/echo -e ${ISC_PACKAGE_MGRUSER}\\tALL=\(ALL\)\\tNOPASSWD: ALL >> /etc/sudoers && \
	sudo -u ${ISC_PACKAGE_MGRUSER} sudo echo enabled passwordless sudo-ing for ${ISC_PACKAGE_MGRUSER}

USER ${ISC_PACKAGE_MGRUSER}

# RUN pip3 install --index-url https://registry.intersystems.com/pypi/simple --no-cache-dir --target /usr/irissys/mgr/python intersystems-iris-automl
RUN pip3 install -r requirements.txt --index-url https://registry.intersystems.com/pypi/simple --no-cache-dir --target /usr/irissys/mgr/python

# START load demo data
# COPY data /data
COPY iris.script /tmp/iris.script
RUN iris start IRIS \
	&& iris session IRIS < ./iris.script
# END load demo data
