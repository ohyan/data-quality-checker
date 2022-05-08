FROM ubuntu:18.04
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN apt-get update && apt-get install -y git \
    && apt-get install wget \
    && apt-get install -y curl && \
    apt-get install -y sudo

# It is needed to setup timezone to install python3.9
# Todo: add reference link
ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN sudo apt-get install -y software-properties-common && \
    sudo add-apt-repository ppa:deadsnakes/ppa && \
    sudo apt-get install -y python3.9 && \
    sudo apt-get install -y python3.9-distutils

RUN sudo curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
RUN python3.9 get-pip.py

ENV CLOUDQ_VERSION 0.5.3
ENV TARGET_OS ubuntu_18
ENV TARGET_PYTHON_INTERPRETER 3.8

RUN git clone -b v${CLOUDQ_VERSION} https://github.com/GoogleCloudPlatform/cloud-data-quality.git
RUN pip3 install -r cloud-data-quality/requirements.txt

WORKDIR /cloud-data-quality
RUN wget -O clouddq_executable.zip https://github.com/GoogleCloudPlatform/cloud-data-quality/releases/download/v${CLOUDQ_VERSION}/clouddq_executable_v${CLOUDQ_VERSION}_${TARGET_OS}_python${TARGET_PYTHON_INTERPRETER}.zip

ENV GOOGLE_CLOUD_PROJECT {GOOGLE_CLOUD_PROJECT}
ENV CLOUDDQ_BIGQUERY_REGION ${CLOUDDQ_BIGQUERY_REGION}
ENV CLOUDDQ_BIGQUERY_DATASET ${CLOUDDQ_BIGQUERY_DATASET}
ENV CLOUD_BIGQUERY_TABLE = ${CLOUD_BIGQUERY_TABLE}
RUN sed -i s/\<your_gcp_project_id\>/${GOOGLE_CLOUD_PROJECT}/g configs/entities/test-data.yml
RUN sed -i s/\<your_bigquery_dataset_id\>/${CLOUDDQ_BIGQUERY_DATASET}/g configs/entities/test-data.yml

RUN rm /usr/bin/python3
RUN ln -s /usr/bin/python3.9 /usr/bin/python3
RUN ln -s /usr/bin/python3.9 /usr/bin/python
RUN python3.9 clouddq_executable.zip \
    ALL \
    configs \
    --gcp_project_id="${GOOGLE_CLOUD_PROJECT}" \
    --gcp_bq_dataset_id="${CLOUDDQ_BIGQUERY_DATASET}" \
    --gcp_region_id="${CLOUDDQ_BIGQUERY_REGION}" \
    --target_bigquery_summary_table="${GOOGLE_CLOUD_PROJECT}.${CLOUDDQ_BIGQUERY_DATASET}.${CLOUD_BIGQUERY_TABLE}"
