<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Location_Latitude_Update</fullName>
        <field>Location__Latitude__s</field>
        <formula>BillingLatitude</formula>
        <name>Location Latitude Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Location_Longitude_Update</fullName>
        <field>Location__Longitude__s</field>
        <formula>BillingLongitude</formula>
        <name>Location Longitude Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Account Location Update</fullName>
        <actions>
            <name>Location_Latitude_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Location_Longitude_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(ISNEW() || ISCHANGED( BillingLatitude) ||  ISCHANGED(  BillingLongitude )) &amp;&amp; BillingLatitude!=null &amp;&amp;BillingLongitude !=null</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
