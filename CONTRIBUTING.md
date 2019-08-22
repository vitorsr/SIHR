# Contributing

[![Maintenance](https://img.shields.io/maintenance/yes/2019)](https://github.com/vitorsr/SIHR/graphs/contributors)
[![GitHub last commit](https://img.shields.io/github/last-commit/vitorsr/SIHR)](https://github.com/vitorsr/SIHR/commits/master)

**TL;DR: send contributions through PRs. Please try to use matrix operations in your implementations. Create an issue for problems and support.**

This document has the purpose of informing how to effectively contribute to this repository.

This repository (`SIHR`) is intented for reproduction and development of single image highlight removal methods, so the biggest challenge isn't even coding, rather, reading the related research papers and *deciphering* how to implement them.

So, please don't feel overwhelmed by the amount of minute detail on contributing, it's mostly to give an overview should you need additional information on general MATLAB/GNU Octave development.

There is a number of ways you can help, and it's not restricted to code contributions.

In the first section (below) I'll put down a few words on non-code contributions.

*Note: since deep learning models typically require a whole project for a complete "reproducibility suite", these will not be **initially** accounted for in this repository. In addition, they are outside the **current** domain of application for these methods (image enhancement for visual display systems). On a future version, perhaps.*

## Call for collaboration

If you'd like to collaborate on a survey on this specific subject, please contact me. You can find contact information [here](#contact). I have set up a SIHR interest group on [Mendeley ![Mendeley](https://cdn1.iconfinder.com/data/icons/simple-icons/16/mendeley-16-black.png)](https://www.mendeley.com/community/sihr/) for this purpose.

<!-- https://www.iconfinder.com/icons/167730/mendeley_icon -->

## Issues

[![GitHub issues](https://img.shields.io/github/issues/vitorsr/SIHR)](https://github.com/vitorsr/SIHR/issues)

Since we're a small community and this is a rather small repository, feel free to create an issue with any comments on bugs, improvements, compatibility problems, etc. and I will get to them eventually (or hopefully someone else will first).

## Testing

As the methods are single-input, single-output, general testing and functionality verification is done by simply invoking the methods' functions with a valid input.

Additionally on a general note, I expect that new methods contributed fulfill the `I_d = AuthorYEAR(I);` command, `I` being any input image of numeric floating-point class `single | double` representing linear RGB values in `[0, 1]` and size *M*×*N*×3, *M* and *N* non-zero, non-singleton, positive integers, and `I_d` the corresponding diffuse image of same class, domain and dimension.

In short: double RGB image in, double RGB image out.

Note: there is a [`utils/my_quality.m`](https://github.com/vitorsr/SIHR/blob/master/utils/my_clip.m) script to reproduce reported quality results. Be warned that `Tan2005`, `Yoon2006` and `Akashi2016` run very slowly on Octave (lots of iterations).

## Submitting changes

Please send a [pull request](https://github.com/vitorsr/SIHR/pull/new/master) to the main repository. Please follow the coding conventions (below) to some extent and make sure all of your commits are restricted to either one method or one general modification per commit. Try to write a concise log message for the commits.

## Coding conventions

The beauty in MATLAB/GNU Octave syntax is that there's nothing exquisite about it, it just stays out of your way in favor of mathematics-oriented programming. Just try to keep it tidy. And **always** favor matrix operations.

Some loose tips on formatting:

1. On MATLAB:
    * Please use **default** [smart identing](https://www.mathworks.com/help/matlab/matlab_prog/improve-code-readability.html) settings. Apply in editor via <kbd>Ctrl</kbd> + <kbd>I</kbd> or <kbd>⌘ Cmd</kbd> + <kbd>I</kbd>
      * Exception can be made for aligned comments, assignments and general data
    * Optionally, use [MBeautifier](https://github.com/davidvarga/MBeautifier)
      * I recommend adding the provided [shortcuts](https://github.com/davidvarga/MBeautifier#shortcuts)
      * To disable (for, e.g. same case as above), see the [directives](https://github.com/davidvarga/MBeautifier#directives)
2. On Octave:
    * Follow the [Octave style guide](https://wiki.octave.org/Octave_style_guide) to some extent

Some tips on matrix-vector coding:

* **Always** prefer operations in the following order: matrix ≻ array ≻ scalar
  * From the MATLAB documentation: [Techniques to Improve Performance](https://www.mathworks.com/help/matlab/matlab_prog/techniques-for-improving-performance.html)
  * From the Octave documentation: [Basic Vectorization](https://octave.org/doc/interpreter/Vectorization-and-Faster-Code-Execution.html)
* [`bsxfun`](https://www.mathworks.com/help/matlab/ref/bsxfun.html) is needed for MATLAB versions earlier than 2016b for implicit expansion
  * Octave also supports implicit expansion. It goes by the name of [broadcasting](https://octave.org/doc/interpreter/Broadcasting.html)
* Short "books"
  * [Good MATLAB Coding Practices](https://blogs.mathworks.com/pick/2011/01/14/good-matlab-coding-practices/)
    * [Writing Fast MATLAB Code](https://www.mathworks.com/matlabcentral/fileexchange/5685-writing-fast-matlab-code)
    * [Guidelines for writing clean and fast code in MATLAB](https://www.mathworks.com/matlabcentral/fileexchange/22943-guidelines-for-writing-clean-and-fast-code-in-matlab)

### A word on `help` text

Please follow the MATLAB basic structure for `help` text: [Add Help for Your Program](https://www.mathworks.com/help/matlab/matlab_prog/add-help-for-your-program.html).

Octave provides additional stylistic guidelines: [Help text](https://wiki.octave.org/Help_text#Guidelines).

### A word on MATLAB ↔ Octave compatibility

Octave is "less compatible" with MATLAB than the inverse relation. Reason being that Octave is not merely an open-source copy of MATLAB and actually has its own language extensions.

See this wikibooks entry: [MATLAB Programming/Differences between Octave and MATLAB](https://en.wikibooks.org/wiki/MATLAB_Programming/Differences_between_Octave_and_MATLAB).

My personal recommendation is to code in MATLAB-style syntax and then check Octave for *functionality* compatibility. In case of incompatibility, either change algorithmic/coding approach or implement the desired functionality from scratch.

You can use the [`utils`](https://github.com/vitorsr/SIHR/tree/master/utils) folder for such eventual functions.

## Code of conduct

Please be polite.

## Contact

Vítor Ramos [![ORCID](https://orcid.org/sites/default/files/images/orcid_16x16.png)](https://orcid.org/0000-0002-7583-5577)  
E-mail: [`vitorsr+SIHR@ufrn.edu.br`](mailto:vitorsr+SIHR@ufrn.edu.br)<sup>1</sup>

<sup>1</sup> `+SIHR` [works](https://gmail.googleblog.com/2008/03/2-hidden-ways-to-get-more-from-your.html), please append it so I know where you're coming from
