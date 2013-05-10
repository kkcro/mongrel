#! /bin/bash
VERSION=1.2.6
LIB_NAME=mongrel
BUILD_NAME=$LIB_NAME-$VERSION

# If an archive already exists, delete it.
ls $LIB_NAME-*.zip >/dev/null 2>/dev/null
if [ $? -eq 0 ]
then
    rm $LIB_NAME-*.zip
fi

# Create directories for the build artifacts.
mkdir $BUILD_NAME
mkdir $BUILD_NAME/doc
mkdir $BUILD_NAME/ebin
mkdir $BUILD_NAME/tbin

# Compile the source and the tests to separate binary directories.
echo "Compiling..."
erlc -I include -o $BUILD_NAME/ebin src/*.erl
if [ $? -ne 0 ]
then
    rm -r $BUILD_NAME
    echo "Compilation failed."
    exit 1
fi
cp src/$LIB_NAME.app.src $BUILD_NAME/ebin/$LIB_NAME.app
erlc -I include -o $BUILD_NAME/tbin test/*.erl
if [ $? -ne 0 ]
then
    rm -r $BUILD_NAME
    echo "Tests couldn't be compiled."
    exit 1
fi

# Run all the tests.
echo "Running tests..."
erl -noshell -pa $BUILD_NAME/ebin -pa $BUILD_NAME/tbin -s test_all test $BUILD_NAME/tbin -s init stop
if [ $? -ne 0 ]
then
    rm -r $BUILD_NAME
    echo "Not all tests passed."
    exit 1
fi

# We don't need to keep the test binaries.
rm -r $BUILD_NAME/tbin

# Create the EDocs.
echo "Generating EDocs..."
cp doc/overview.edoc $BUILD_NAME/doc
./gen_doc.sh $BUILD_NAME/doc
if [ $? -ne 0 ]
then
    rm -r $BUILD_NAME
    echo "Errors while generating EDocs."
    exit 1
fi

# Copy source files into the artifacts directory.
rsync -p -r --exclude=".*" src $BUILD_NAME
rsync -p -r --exclude=".*" test $BUILD_NAME
rsync -p -r --exclude=".*" include $BUILD_NAME
rsync -p -r --exclude=".*" src_examples $BUILD_NAME
cp make_mongrel.sh $BUILD_NAME
cp gen_doc.sh $BUILD_NAME
cp releases.txt $BUILD_NAME

# Zip it all up.
echo "Packaging..."
zip -q $BUILD_NAME.zip -r $BUILD_NAME
#tar cjf $BUILD_NAME.tar.gz $BUILD_NAME
rm -r $BUILD_NAME

echo "OK."
exit 0

