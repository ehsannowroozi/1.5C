## Improving the Security of Image Manipulation Detection through One-and-a-half-class Multiple Classification

2018-2019 Department of Information Engineering and Mathematics, University of Siena, Italy.

Author:  Ehsan Nowroozi (Ehsan.Nowroozi65@gmail.com)

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details. You should have received a copy of the GNU General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.

If you are using this software, please cite from [Arxiv](https://dblp.uni-trier.de/rec/bibtex/journals/corr/abs-1902-08446). Also, you can find this paper in the journal Springer-Multimedia Tools and Applications.

### Training 1.5C

#### 1. Choice of Feature set,
   
   With regard to the choice of the feature set, the features have to be powerful enough to capture the different types of 
dependencies among neighboring pixels in the pristine and manipulated images. Also, we want to keep the dimensionality of
the feature set limited, so to make it possible to design the intermediate and combination classifiers as SVMs, without
resorting to more complicated architecture such as ensemble classifiers. Specifically, we selected the [Subtractive Pixel
Adjacency Model (SPAM)](http://dde.binghamton.edu/download/feature_extractors/download/spam686.m) feature set, which extensively used in image forensic applications. In Fact, SPAM features are designed for grayscale images; when working with color images, they can be extracted from the luminance channel. You can find the whole code in the folder "FeatureComputation". Also, You need to run only the code "FeatureComputation.m"

Please see the section of 3.2 regarding implementation of 1.5C and Choice of the Feature Set.







## Welcome to GitHub Pages

You can use the [editor on GitHub](https://github.com/ehsannowroozi/1.5C/edit/master/README.md) to maintain and preview the content for your website in Markdown files.

Whenever you commit to this repository, GitHub Pages will run [Jekyll](https://jekyllrb.com/) to rebuild the pages in your site, from the content in your Markdown files.

### Markdown

Markdown is a lightweight and easy-to-use syntax for styling your writing. It includes conventions for

```markdown
Syntax highlighted code block

# Header 1
## Header 2
### Header 3

- Bulleted
- List

1. Numbered
2. List

**Bold** and _Italic_ and `Code` text

[Link](url) and ![Image](src)
```

For more details see [GitHub Flavored Markdown](https://guides.github.com/features/mastering-markdown/).

### Jekyll Themes

Your Pages site will use the layout and styles from the Jekyll theme you have selected in your [repository settings](https://github.com/ehsannowroozi/1.5C/settings). The name of this theme is saved in the Jekyll `_config.yml` configuration file.

### Support or Contact

Having trouble with Pages? Check out our [documentation](https://help.github.com/categories/github-pages-basics/) or [contact support](https://github.com/contact) and we’ll help you sort it out.
