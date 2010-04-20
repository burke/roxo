== What is?

ROXO (Ruby Objects for XML Objects) is a simple wrapper that uses LibXML to let you traverse an XML document using ruby method calls.

== How do I make it go?

    require 'roxo'
    roxo = ROXO.new("<foo bar='zxcv'><qux><quux>corge</quux></qux><qux>grault</qux></foo>")
    roxo.bar #=> "zxcv"
    roxo.quxes #=> [#<ROXO:0x03158150>, "grault"]
    roxo.quxes.first.quux #=> "corge"

== Is there anything else I need to know?

No.


