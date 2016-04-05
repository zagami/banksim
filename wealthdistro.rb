$foo = [10,10,10,10,10]
def dotrx
while true do
foo = $foo
i = rand foo.length
j = rand foo.length
amount = rand(foo[j])
foo[i] += amount
  foo[j] -= amount
p foo
gets
end
end
