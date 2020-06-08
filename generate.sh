#!/bin/bash

# replace with applicationId to check logs:
# yarn logs -applicationId application_1586456293454_0113


# job variables
# ==========
# ==========

env=geomesa
py="3.7.7"
run="./main.py"

# WM username (without the @CAMPUS.WM.EDU part)
wmuser=dsmillerrunfol

conda_dir=${HOME}

# uncomment if using conda installed in working dir
#conda_dir=$(pwd)

# ==========
# ==========

wd=$(pwd)
mkdir tests


if [[ $(basename $(pwd)) != ${env} ]]; then
    echo "Current directory does not match Conda environment name"
    exit 1
fi

# instead of running the following init and source commands each time in
# future, you could also add `source ${HOME}/.bashrc` to your
# ${HOME}/.bash_profile file (bash_profile is run on login, bashrc is not)

# init conda
#${conda_dir}/anaconda3/bin/conda init
# enable path to conda install set by init
#source ${HOME}/.bashrc

# make sure no env is active
conda deactivate

echo "----------------------------------------"
echo "Building Conda Environment"

# packages can be installed using conda, conda-forge, or pip
#
# *** unless you need to install using special options, use
#     the appropriate *-requirements.txt file for installations
#
# if doing custom install, try installing packages in above order
#    - e.g., try to user conda before resorting to pip
#    - if using pip, do so after installing everything you
#    need to with conda
#    - pip info: https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-pkgs.html


# create conda environment
conda create -y -n ${env} --copy python=${py}
conda activate ${env}


# link CDH pyspark to env
# ln -s /opt/cloudera/parcels/CDH-6.2.0-1.cdh6.2.0.p0.967373/lib/spark/python/pyspark ~/anaconda3/envs/${env}/lib/python3.6/site-packages/pyspark



# make sure these are always installed
conda install -y python-hdfs

# conda requirements
if [[ -f conda-requirements.txt ]];then
    conda install -y --file conda-requirements.txt
else
    echo "No conda-requirements.txt file found"
fi

# conda custom install (uncomment to use)
# ==========
# conda install -y ...
# ==========

# conda-forge requirements
if [[ -f conda-forge-requirements.txt ]];then
    conda install -y --channel conda-forge --file conda-forge-requirements.txt
else
    echo "No conda-forge-requirements.txt file found"
fi

# conda-forge custom install (uncomment to use)
# ==========
# conda install -y --channel conda-forge ...
# ==========

# pip requirements
if [[ -f pip-requirements.txt ]];then
    pip install -r pip-requirements.txt
else
    echo "No pip-requirements.txt file found"
fi



# pip custom install (uncomment to use)
# ==========
pip install --no-dependencies pytz 
# ==========



echo "----------------------------------------"
echo "Zipping Conda Environment"

# zip conda environment
cd ${conda_dir}/anaconda3/envs
zip -r ${wd}/${env}.zip ${env}
cd ${wd}

conda deactivate


echo "----------------------------------------"
echo "Create main spark-submit file"

# create spark submit file using conda environment
cat << EOF > ss-${env}
spark-submit \
--deploy-mode cluster \
--driver-memory=20g \
--conf spark.pyspark.driver.python=${conda_dir}/anaconda3/envs/${env}/bin/python \
--conf spark.pyspark.python=./ENV/${env}/bin/python \
--archives ${wd}/${env}.zip#ENV,/opt/cloudera/parcels/CDH-6.2.0-1.cdh6.2.0.p0.967373/lib/spark/python/lib/py4j-0.10.7-src.zip \
--jars ${jar_path},/opt/cloudera/parcels/CDH-6.2.0-1.cdh6.2.0.p0.967373/jars/httpclient-4.5.3.jar,/opt/cloudera/parcels/CDH-6.2.0-1.cdh6.2.0.p0.967373/jars/commons-httpclient-3.1.jar \
${run}
EOF

# create pyspark file
cat << EOF > ps-${env}
pyspark \
--driver-memory=20g \
--conf spark.pyspark.driver.python=${conda_dir}/anaconda3/envs/${env}/bin/python \
--conf spark.pyspark.python=./ENV/${env}/bin/python \
--archives ${wd}/${env}.zip#ENV,/opt/cloudera/parcels/CDH-6.2.0-1.cdh6.2.0.p0.967373/lib/spark/python/lib/py4j-0.10.7-src.zip \
--jars ${jar_path},/opt/cloudera/parcels/CDH-6.2.0-1.cdh6.2.0.p0.967373/jars/httpclient-4.5.3.jar,/opt/cloudera/parcels/CDH-6.2.0-1.cdh6.2.0.p0.967373/jars/commons-httpclient-3.1.jar
EOF

