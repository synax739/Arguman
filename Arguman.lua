local test = Drawing.new("Square")
if test then
    test.Visible = true
    test.Size = Vector2.new(100, 100)
    test.Position = Vector2.new(100, 100)
    test.Color = Color3.new(1,0,0)
    print("Drawing ÇALIŞIYOR")
else
    print("Drawing ÇALIŞMIYOR - Delta'yı güncelle ya da farklı bir exploit dene")
end
