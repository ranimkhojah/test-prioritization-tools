import codecs

filename = "d2v_p1.csv"
f = codecs.open(filename,encoding='utf-8')
contents = f.read()
new_content = contents.replace(",",";")
m = codecs.open(filename, "w" ,encoding='utf-8')
m.write(new_content)
