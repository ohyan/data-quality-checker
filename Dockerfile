FROM ubuntu:18.10

COPY env_versions /var/env_versions
RUN source /var/env_versions

RUN git clone -b "v${CLOUDQ_VERSION}" https://github.com/GoogleCloudPlatform/cloud-data-quality.git
RUN source cloud-data-quality/scripts/install_python3.sh "3.9.7"
RUN cd cloud-data-quality
RUN wget -O clouddq_executable.zip https://github.com/GoogleCloudPlatform/cloud-data-quality/releases/download/v"${CLOUDQ_VERSION}"/clouddq_executable_v"${CLOUDQ_VERSION}"_"${TARGET_OS}"_python"${TARGET_PYTHON_INTERPRETER}".zip
