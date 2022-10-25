FROM nvidia/cuda:11.2.1-cudnn8-runtime-ubuntu20.04

# INSTALL PYTHON 3.9
RUN apt-get update -y
RUN apt-get install software-properties-common -y
RUN add-apt-repository ppa:deadsnakes/ppa -y
RUN apt-get install python3.9 -y
RUN apt-get install python3-pip -y
RUN apt-get -y install git

RUN apt install python-is-python3 -y
RUN alias python=python3.9

# INSTALL PROTOBUF
# Easy Way
RUN apt-get install protobuf-compiler python-pil python-lxml -y

# RUN protoc --version
# INSTALL TENSORFLOW API
RUN pip install --ignore-installed --upgrade tensorflow==2.5.0

RUN mkdir tensorflow/
RUN mkdir tensorflow/models
RUN git clone https://github.com/tensorflow/models tensorflow/models

WORKDIR "/tensorflow/models/research"
RUN protoc object_detection/protos/*.proto --python_out=.
RUN export PYTHONPATH=$PYTHONPATH:`pwd`:`pwd`/slim

WORKDIR /

RUN pip install cython
RUN git clone https://github.com/cocodataset/cocoapi.git
WORKDIR "cocoapi/PythonAPI"
RUN make
RUN cp -r pycocotools /tensorflow/models/research/


WORKDIR /
WORKDIR "/tensorflow/models/research"
RUN cp object_detection/packages/tf2/setup.py .
RUN python -m pip install .
WORKDIR /


# Easy visualize
RUN pip install jupyter
RUN pip install matplotlib

RUN jupyter notebook --generate-config --allow-root
RUN echo "c.NotebookApp.password = u'sha1:6a3f528eec40:6e896b6e4828f525a6e20e5411cd1c8075d68619'" >> /root/.jupyter/jupyter_notebook_config.py

# EXPOSE 8888
CMD ["BASH"]
#CMD ["jupyter", "notebook", "--allow-root", "--notebook-dir=/tensorflow/models/research/object_detection", "--ip=0.0.0.0", "--port=8888", "--no-browser"]