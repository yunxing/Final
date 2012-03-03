import sys
import os
from jinja2 import Template

print "Translating template files..."
filenames=os.listdir(os.getcwd()+'/template')
for fileName in filenames:
    input = open('template/'+fileName, 'r')
    template = Template(input.read())
    output = open('verilog/'+fileName, 'w')
    output.write(template.render(ways=8))

input.close()
output.close()
print "Translating finished..."
