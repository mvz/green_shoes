require '../lib/green_shoes'

Shoes.app width: 300, height: 300 do
  background cadetblue
  r = rect 100, 10, 100, fill: red, strokewidth: 5, curve: 10, stroke: pink
  r.click{alert 'Yay!'}
  o = oval 100, 110, 100, 100, fill: green, strokewidth: 10, stroke: white
  para 'Green Shoes!!', left: 100, top: 70

  size = COLORS.keys.size
  j = 0
  a = animate 1 do |i|
    unless j == i
      r.style fill: send(COLORS.keys[rand size]), stroke: send(COLORS.keys[rand size]), noorder: true
      o.style fill: send(COLORS.keys[rand size]), stroke: send(COLORS.keys[rand size])
      j = i
    end
  end

  button('pause'){a.pause}
end
