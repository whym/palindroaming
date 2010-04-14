Palindroaming -- palindrome generator based on language model
=====================================================================

Requirements
-------------
- ruby_
- mecab_

.. _ruby: http://ruby-lang.org
.. _mecab: http://mecab.sourceforge.net

How to use
--------------
*Current Palindroaming can generate Japanese language only.*

1. 日本語のテキストを多めに（少なくとも100kb以上）用意し、 INPUT_FILE として保存（名前は任意）。
2. cat INPUT_FILE | ./gen-phone-model.rb --order 2 > phone.pmod
3. ./palindroaming.rb  --length 5 --phone phone.pmod --order 2


How it works
--------------
- Phone segmentation and N-phone model construction
- Sampling from N-phone model

Todo
-----
- Machine-learning based classification of good and bad palindrome
