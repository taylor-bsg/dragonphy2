# create virtual environment
$DRAGONPHY_PYTHON -m venv venv
source venv/bin/activate

# upgrade pip
pip install -U pip

# install dragonphy
pip install -e .

# make dependencies for design
make all

# install pytest
pip install pytest pytest-cov

# install DaVE
git clone https://github.com/StanfordVLSI/DaVE.git
export mLINGUA_DIR=`realpath DaVE/mLingua`

# run tests
pytest tests -s -v -r s --cov-report=xml --cov=dragonphy

# upload coverage
bash <(curl -s https://codecov.io/bash)

# deactivate virtual env
deactivate