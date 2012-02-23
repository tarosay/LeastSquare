------------------------------------------
--最小二乗近似曲線を求めるプログラム
------------------------------------------
--関数宣言--------------------------------
main={}			--mainメソッド
printscrl={}	--スクロール有り文字表示
gauss={}		--ガウス消去を行う
split={}		--文字の分解
readdata={}		--CSVファイルを読み込みます
kinji={}		--近似計算
rculc={}		-- 決定係数R^2の計算
InputData={} --データを入力します
setDirection={} -- 縦横の自動設定



--グローバル変数宣言----------------------
AppPath = system.getAppPath().."/"		--アプリのPAth
Fname = "leastsquare.csv"
Value ={ X={}, Y={} }
Col = { White=color(255,255,255), Black = color(0,0,0), Red=color(255,0,0) }
------------------------------------------
mt={}
mt.__newindex=function(mtt,mtn,mtv)
 dialog( "Error Message", "宣言していない変数 "..mtn.." に値を入れようとしています", 0 )
 toast("画面タッチで実行を続けます", 1)
 touch(3)
end
mt.__index=function(mtt,mtn)
 dialog( "Error Message", "変数 "..mtn.." は宣言されていません", 0 )
 toast("画面タッチで実行を続けます", 1)
 touch(3)
end
setmetatable(_G,mt)
--------以下が実プログラム----------------
------------------------------------------
--スクロールするテキスト表示
------------------------------------------
function printscrl( str, fontsize, fcolor, bcolor )
local w,h = canvas.getviewSize()
 --一度、見えないところにテキストを書いて、改行数を求める
 local sc = canvas.putTextBox( str, 0, h+1, fontsize, fcolor, w )
 --画面の絵をワークエリアに取り込みます
 canvas.getg( 0, fontsize*sc, w-1, h-1, 0, fontsize*sc, w-1, h-1 )
 --取り込んだ画面をスクロールさせて描きます
 canvas.putg( 0, 0, w-1, h-fontsize*sc-1, 0, fontsize*sc, w-1, h-1 )
 --書き出す部分をバックカラーで塗り潰します
 canvas.putRect(  0, h-fontsize*sc-1, w, h, bcolor, 1 )
 --スクロールしたところにテキストを書きます
 canvas.drawTextBox( str, 0, h-fontsize*sc, fontsize, fcolor, w )
end
------------------------------------------
--ガウス消去を行います
-- a[n][n+1]配列です
------------------------------------------
function gauss( a, n )
local i,j,k,l
local m
local pivot
local b
local p,q
local x={}
	
	for i=1,n do
		m = 0
		pivot = i
		for l=i,n do
			--i列の中で一番値が大きい行を選ぶ
			if( math.abs( a[l][i] )>m )then
				m = math.abs( a[l][i] )
				pivot = l
			end
		end
		--pivotがiと違えば、行の入れ替え
		if( pivot~=i )then
			for j=1,n+1 do
				b = a[i][j]
				a[i][j] = a[pivot][j]
				a[pivot][j] = b
			end
		end
	end
	for k=1,n do
		p = a[k][k]		--対角要素を保存
		--対角要素は1になることがわかっているので直接代入
		a[k][k] = 1
		for j=k+1,n+1 do
			a[k][j] = a[k][j] / p
		end
		for i=k+1,n do
			q = a[i][k]
			for j=k+1,n+1 do
				a[i][j] = a[i][j] - q*a[k][j]
			end
			--0となることがわかっているので直接代入
			a[i][k] = 0
		end
	end
	--解の計算
--[[	for k=1,n do
		i = n - k + 1
		x[i]=a[i][n+1]
		for l=i+1,n do
			j = n - l + i +1
			x[i] = x[i] - a[i][j]*x[j]
		end
	end
--]]
	for i=n,1,-1 do
		x[i] = a[i][n+1]
		for j=n,i+1,-1 do
			x[i] = x[i] - a[i][j]*x[j]
		end
	end

	--行列が最後どうなったか見たいときに実行
	--for i=1,n do
	--	for j=1,n+1 do
	--		printscrl( a[i][j], 20, color(0,0,0), color(255,255,255) )
	--	end
	--end
	return( x )
end
------------------------------------------
--文字の分解
------------------------------------------
function split(str, d)
local s = str
local t = {}
local p = "%s*(.-)%s*"..d.."%s*"
local f = function(v)	table.insert(t, v)	end

	if s ~= nil then
		string.gsub(s, p, f)
		f(string.gsub(s, p, ""))
	end
	return t
end
------------------------------------------
--CSVファイルを読み込みます
------------------------------------------
function readdata( filename )
local fp
local msg
local str
local t={}
local i = 1

	--ファイルを開きます
	fp,msg = io.open( Path..filename, "r")
	if( not(fp) )then
		dialog( Path..Fname.."がオープンできません","プログラムを終了します", 0 )
		return
	end

	--CSVデータを読み込みます
	while(true)do
		str = fp:read("*l")					--1行読み込み
		if( str==nil )then break end		--読込むデータが無ければ終了
		str = string.gsub( str,"\r","" )	--改行コードを外す

		t = split( str, "," )
		if( t[1]~=nil and t[2]~=nil )then
			Value.X[i] = t[1]
			Value.Y[i] = t[2]
			printscrl( "X="..Value.X[i].." Y="..Value.Y[i], 18, color(0,0,0), color(255,255,255) )
			i = i + 1
		end
	end
	io.close(fp)
end
------------------------------------------
--近似計算
-- k次近似
------------------------------------------
function kinji( k )
local gn
local a={
		{0,0,0,0,0,0,0,0}
		,{0,0,0,0,0,0,0,0}
		,{0,0,0,0,0,0,0,0}
		,{0,0,0,0,0,0,0,0}
		,{0,0,0,0,0,0,0,0}
		,{0,0,0,0,0,0,0,0}
		,{0,0,0,0,0,0,0,0}
		}
local n = #Value.X
local px
local i,j
local x={}
local r
local sk
	
	gn = k + 1
	a[1][1] = n
	for i=1, n do
		px = 1
		for j=1,gn-2 do
			px = px*Value.X[i]
			a[1][j+1] = a[1][j+1] + px
		end
		px = 1
		for j=3,gn do
			px = px*Value.X[i]
		end
		for j=1,gn do
			px = px*Value.X[i]
			a[j][gn] = a[j][gn] + px
		end
		px = 1
		for j=0,gn-1 do
			a[j+1][gn+1] = a[j+1][gn+1] + Value.Y[i]*px
			px = px * Value.X[i]
		end
	end
	for i=2,gn do
		for j=1,gn-1 do
			a[i][j] = a[i-1][j+1]
		end
	end

	--for i=1,gn do
	--	printscrl( a[i][1].." "..a[i][2].." "..a[i][3].." "..a[i][4].." "..a[i][5], 20, color(0,0,0), color(255,255,255) )
	--end

	--ガウス消去を行います
	x = gauss( a, gn )

--[[	printscrl( " ", 20, color(0,0,0), color(255,255,255) )
	printscrl( "　"..k.." 次曲線近似式", 20, color(0,0,0), color(255,255,255) )
	printscrl( "Y=Σ(Ai*X^i) (i=0～"..k..")", 20, color(0,0,0), color(255,255,255) )
	for i=0,k do
		printscrl( "A"..i.."="..x[i+1], 20, color(0,0,0), color(255,255,255) )
	end
--]]
	-- 決定係数R^2の計算
	r,sk  = rculc( x, k )

	return x,r,sk
end
------------------------------------------
-- 決定係数R^2の計算
------------------------------------------
function rculc( x, k )
local ave = 0
local i,j
local n = #Value.X
local bo = 0
local si = 0
local kb = 0
local f,px
local r,sk

	for i=1,n do
		ave = ave + Value.Y[i]
	end
	ave = ave / n
	for i=1,n do
		f = 0
		px = 1
		for j=0,k do
			f = f + x[j+1]*px
			px = px*Value.X[i]
		end
		bo = bo + (Value.Y[i]-ave)*(Value.Y[i]-ave)
		si = si + (f-ave)*(f-ave)
		kb = kb + (Value.Y[i]-ave)*(f-ave)
	end

	--決定係数R^2=(Grkb*Grkb)/(Grbo*Grsi)
	r = kb*kb/si/bo
	--相関係数R=Grkb/{√(Grbo)*√(Grsi)} 
	sk = kb/(math.sqrt(bo)*math.sqrt(si))
	return r, sk
end
------------------------------------------
--データを入力します
------------------------------------------
function InputData( kazu )
local i = 1
	while(true)do
		local data, s = editText("カンマで区切って、X, Y を入力してください")
		if( s==nil or data==nil or data==""  )then
			break
		elseif( s==1 )then
			if( data=="" )then break end
			local h = string.find (data, "," )
			if( h==1 )then break end
			local d={}
			d = split( data, ',' )
			if( tonumber(d[1])==nil or tonumber(d[2])==nil )then break end
			Value.X[i] = d[1]
			Value.Y[i] = d[2]
			i = i + 1
		else
			break
		end
	end
	if( kazu+1<i )then
		return true
	else
		return false
	end
end
------------------------------------------
-- 縦横の自動設定
------------------------------------------
function setDirection()
local i
local ax,ay
	sensor.setdevAccel( 1 )	--加速度センサ起動
	for i=1,32 do
		ax, ay = sensor.getAccel()
	end
	sensor.setdevAccel( 0 )	--加速度センサオフ
	if( ax<5 and ay>5 )then
		system.setScreen(1)   --縦向きに変更
		--内部グラフィック画面設定の変更
		local w,h = canvas.getviewSize()
		canvas.setMainBmp( w, h )
	end
 end
------------------------------------------
--メインプログラム
------------------------------------------
function main()
local k
local x={}
local i
local r,sk
local s

	-- 縦横画面の自動設定
	setDirection()
	--画面を白くする
	canvas.drawCls( color(255,255,255) )
	--選択ダイアログのセット
	item.clear()
	item.add( "1次近似", 0 )
	item.add( "2次近似", 0 )
	item.add( "3次近似", 0 )
	item.add( "4次近似", 0 )
	item.add( "5次近似", 0 )
	item.add( "6次近似", 0 )
	k = item.radio("何次近似を行いますか", 1 )
	if( k==0 )then
		dialog( "最小二乗近似計算", "プログラムを終了します", 1 )
		El_Psy_Congroo()
	end
	--データを入力します
	while( true)do
		s = 1
		if( InputData( k )==true )then break end
		s = dialog( k.."次近似を行うにはデータ数が足りません", "データを入力し直してください",  2)
		if( s~=1 )then break end
	end

	if( s~=1 )then
		dialog( "最小二乗近似計算", "プログラムを終了します", 1 )
		El_Psy_Congroo()
	end
	
	--k次近似式を求めます
	x, r, sk = kinji( k )

	--データの表示
	for i=1, #Value.X do
		printscrl( "X= "..Value.X[i].." , Y= "..Value.Y[i], 16, Col.Black, Col.White )	
	end
	
	printscrl( " ", 20, Col.Black, Col.White )
	printscrl( "　"..k.." 次曲線近似式", 20, Col.Black, Col.White )
	printscrl( "Y=Σ(Ai*X^i) (i=0～"..k..")", 20, Col.Black, Col.White )
	for i=0,k do
		printscrl( "A"..i.."="..x[i+1], 20, Col.Black, Col.White )
	end
	printscrl( "R^2= "..r, 20, Col.Red, Col.White )
	printscrl( "R= "..sk, 20, Col.Red, Col.White )
	
	toast("画面タッチで終了します",0)
	touch(3)
end
main()
El_Psy_Congroo()