#!/bin/sh

buildOSX="n"
buildWin32="n"
buildWin64="n"

case $1 in 
	all)
		buildOSX="y"
		buildWin32="y"
		buildWin64="y"
		;;
	osx)
		buildOSX="y"
		;;
	win32)
		buildWin32="y"
		;;
	win64)
		buildWin64="y"
		;;
esac

if [ -f "distr/win-wrapper/planets.exe" ]; then
	useWrapper="y"
else
	useWrapper="n"
fi

# cleaning up
rm -rf build/*
touch build/.gitkeep

# building
echo -n "building .love: "
cd src
zip -0 -r -X -q ../build/planets.love .
cd ..
echo "done"

if [ $buildOSX = "y" ]; then
	echo -n "building osx: "
	if [ -d "distr/osx/love.app" ]; then
		mkdir -p "build/osx"
		cp -r "distr/osx/love.app" "build/osx/planets.app"
		sed "s/org.love2d.love/info.deseven.planets/g" distr/osx/love.app/Contents/Info.plist > build/osx/planets.app/Contents/Info.plist.tmp
		sed "s/LÖVE/planets!!/g" build/osx/planets.app/Contents/Info.plist.tmp > build/osx/planets.app/Contents/Info.plist
		rm -f build/osx/planets.app/Contents/Info.plist.tmp
		cp build/planets.love build/osx/planets.app/Contents/Resources/
		cp -f ico/main.icns build/osx/planets.app/Contents/Resources/Love.icns
		cd build/osx
		zip -9 -q -r ../planets-osx.zip planets.app
		cd ../../
		echo "done"
	else
		echo "skipping"
	fi
fi

if [ $buildWin32 = "y" ]; then
	echo -n "building win32: "
	if [ -d "distr/win32" ]; then
		cp -r "distr/win32" "build/win32"
		cp -f ico/main.ico build/win32/game.ico
		cat build/win32/love.exe build/planets.love > build/win32/planets.exe
		rm build/win32/love.exe
		cd build/win32
		if [ $useWrapper = "y" ]; then
			zip -0 -q -r ../planets-win32.zip .
			cd ..
			printf "0: %.8x" `wc -c < planets-win32.zip` | sed -E 's/0: (..)(..)(..)(..)/0: \4\3\2\1/' | xxd -r -g0 > win32.bin
			cat ../distr/win-wrapper/planets.exe planets-win32.zip win32.bin > planets.exe
			rm -f win32.bin
			rm -f planets-win32.zip
			zip -9 -q planets-win32.zip planets.exe
			rm -f planets.exe
			cd ..
		else
			zip -9 -q -r ../planets-win32.zip .
			cd ../../
		fi
		echo "done"
	else
		echo "skipping"
	fi
fi

if [ $buildWin64 = "y" ]; then
	echo -n "building win64: "
	if [ -d "distr/win64" ]; then
		cp -r "distr/win64" "build/win64"
		cp -f ico/main.ico build/win32/game.ico
		cat build/win64/love.exe build/planets.love > build/win64/planets.exe
		rm build/win64/love.exe
		cd build/win64
		if [ $useWrapper = "y" ]; then
			zip -0 -q -r ../planets-win64.zip .
			cd ..
			printf "0: %.8x" `wc -c < planets-win64.zip` | sed -E 's/0: (..)(..)(..)(..)/0: \4\3\2\1/' | xxd -r -g0 > win64.bin
			cat ../distr/win-wrapper/planets.exe planets-win64.zip win64.bin > planets.exe
			rm -f win64.bin
			rm -f planets-win64.zip
			zip -9 -q planets-win64.zip planets.exe
			rm -f planets.exe
			cd ..
		else
			zip -9 -q -r ../planets-win64.zip .
			cd ../../
		fi
		echo "done"
	else
		echo "skipping"
	fi
fi
