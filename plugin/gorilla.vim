"-
" Copyright 2008 (c) Meikel Brandmeyer.
" All rights reserved.
"
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
" THE SOFTWARE.

" Prolog
if !has("ruby")
    finish
endif

try
    if !gatekeeper#Guard("g:gorilla", "1.0.0")
        finish
    endif
catch /^Vim\%((\a\+)\)\=:E117/
    if exists("g:gorilla_loaded")
        finish
    endif
    let g:gorilla_loaded = "1.0.0"
endtry

let s:save_cpo = &cpo
set cpo&vim

" The Gorilla Module
ruby <<EOF
require 'net/telnet'

module Gorilla
    PROMPT = /^Gorilla=> \z/n

    def Gorilla.connect()
        return Net::Telnet.new("Host" => "127.0.0.1", "Port" => 10123,
                               "Telnetmode" => false, "Prompt" => PROMPT)
    end

    DOCS = {}

    def Gorilla.doc(word)
        if DOCS.has_key?(word)
            return DOCS[word]
        end

        result = ""
        t = Gorilla.connect()
        begin
            t.waitfor(PROMPT)
            result = t.cmd("(doc " + word + ")\n")
        ensure
            t.close
        end

        result.sub(PROMPT, "").split(/\n/)
    end
end
EOF

" Epilog
let &cpo = s:save_cpo
