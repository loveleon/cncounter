# stop_and_publish.sh
# chmod 755 stop_and_publish.sh


# ENV

srcbranch=v0.0.3
srcurl=https://github.com/cncounter/cncounter.git
appname=cncounter-web
withsubmodelname=cncounter-web/cncounter-web
deploybase=/usr/local/cncounter_webapp
tomcatbase=/usr/local/tomcat7

# init

mkdir -p $deploybase/git_source
cd $deploybase/git_source
git clone -b $srcbranch  $srcurl $appname


# package

cd $deploybase/git_source/$appname
git checkout $srcbranch
git pull

cd $deploybase/git_source/$withsubmodelname
mvn clean package -U -DskipTests

if [ ! $? -eq 0 ]
then
    echo "Error in mvn clean package!!! Stop deployment!"
    exit 1
fi


# stop_and_publish

cd $deploybase/
$tomcatbase/bin/shutdown.sh 


mkdir -p $deploybase/bak

rm -rf $deploybase/bak/$appname

mv $deploybase/$appname $deploybase/bak/$appname


rm -f $deploybase/bak/$appname.war

mv $deploybase/$appname.war $deploybase/bak/$appname.war

cp $deploybase/git_source/$withsubmodelname/target/$appname.war $deploybase/


cd $deploybase/

unzip $appname.war -d $appname


rm $tomcatbase/work/* -rf
rm $tomcatbase/temp/* -rf

ping localhost -c 10

cd $deploybase/
$tomcatbase/bin/startup.sh


ping localhost -c 2

tail -n 500 -f $tomcatbase/logs/catalina.out 


