## Improving the Security of Image Manipulation Detection through One-and-a-half-class Multiple Classification

2018-2019 Department of Information Engineering and Mathematics, University of Siena, Italy.

Author:  Ehsan Nowroozi (Ehsan.Nowroozi65@gmail.com)

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details. You should have received a copy of the GNU General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.

If you are using this software, please cite from [Arxiv](https://dblp.uni-trier.de/rec/bibtex/journals/corr/abs-1902-08446). Also, you can find this paper in the journal Springer-Multimedia Tools and Applications.

### Training 1.5C

#### 1. Choice of Feature set,
   
   With regard to the choice of the feature set, the features have to be powerful enough to capture the different types of 
dependencies among neighboring pixels in the pristine and manipulated images. Also, we want to keep the dimensionality of
the feature set limited, so to make it possible to design the intermediate and combination classifiers as SVMs, without resorting to more complicated architecture such as ensemble classifiers. Specifically, we selected the [Subtractive Pixel Adjacency Model (SPAM)](http://dde.binghamton.edu/download/feature_extractors/download/spam686.m) feature set, which extensively used in image forensic applications. In Fact, SPAM features are designed for grayscale images; when working with color images, they can be extracted from the luminance channel. You can find the whole code in the folder "FeatureComputation". Also, You need to run only the code "FeatureComputation.m"

Please see the section of 3.2 regarding implementation of 1.5C and Choice of the Feature Set.

#### 2. Train Two-Class-Classification (2C),

Two class of features which computed in the previous section trained in this section thourgh the "Train_2C.m" which called 2C.

#### 3. Train 1C-Class-Classification (1C),

Regarding the 1C SVM first we need to find the nu and gamma hyper-parameter. Hence, we find the hyper-parameters in the code "SVM_1C_Pristine_HyperParam.m" for 1C pristine and "SVM_1C_Manipulated_HyperParam.m" for 1C Manipulated. Our approach it is same as a grid search which we use for 2C classifier. After finding the hyper parameter the Train code call two parameters nu
and gamma for training.

1C_Pristine: "SVM_1C_Pristine_HyperParam.m" for finding nu and gamma, "Train_SVM_1C_Pristine.m" train 1C pristine with hyper parameters.
   
1C_Manipulated: "SVM_1C_Manipulated_HyperParam.m" for finding nu and gamma, "Train_SVM_1C_Manipulated.m" train 1C manipulated with hyper parameters.

Please see the section of 3.3 regarding how to train the 1.5C Classifier and for hyper-parameter please see the section of 5.1 in the paper.
