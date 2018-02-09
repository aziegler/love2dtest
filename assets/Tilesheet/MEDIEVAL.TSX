<?xml version="1.0" encoding="UTF-8"?>
<tileset name="Medieval" tilewidth="64" tileheight="64" spacing="32" margin="32" tilecount="126" columns="18">
 <image source="medieval_tilesheet.png" width="1760" height="704"/>
 <tile id="0" type="background">
  <properties>
   <property name="groundType" value="grass"/>
  </properties>
 </tile>
 <tile id="1" type="background">
  <properties>
   <property name="groundType" value="grass"/>
  </properties>
 </tile>
 <tile id="2" type="background"/>
 <tile id="4" type="road">
  <properties>
   <property name="down" type="bool" value="true"/>
   <property name="top" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="73">
  <properties>
   <property name="background" value="grass"/>
   <property name="forest" value="0"/>
   <property name="road" value="0000"/>
  </properties>
 </tile>
</tileset>
