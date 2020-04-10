/**
* @Author       Heidi Tang
* @Date         2016-04-25
* @Description  Trigger handler for KeyPlayersTrigger.trigger.
**/
public class KeyPlayersTriggerHandler{ 

    public static boolean runonce=false;
    
    public void onBeforeInsert(List<QS_Key_Players_Influencers__c> newKeyPlayers){
        //check if Key Player with Contact, Opportunity already exist.
        checkAvailability(newKeyPlayers);
    }
    
    public static void updateAllPrimaryCheckboxFalse(){
        map<id,id> opportunityIdVsNewPrimaryKeyPlayerId = new map<id,id>();
        list<QS_Key_Players_Influencers__c> toUpdate = new list<QS_Key_Players_Influencers__c>();
        
        for(QS_Key_Players_Influencers__c keyPlayInfInst : (list<QS_Key_Players_Influencers__c>)Trigger.new){            
            if(keyPlayInfInst.QS_Primary__c==true){
                opportunityIdVsNewPrimaryKeyPlayerId.put(keyPlayInfInst.QS_Opportunity__c, keyPlayInfInst.id);
            }
        }
        
        for(QS_Key_Players_Influencers__c keyPlayInst : [SELECT id,QS_Primary__c,QS_Opportunity__c FROM QS_Key_Players_Influencers__c WHERE QS_Opportunity__c in: opportunityIdVsNewPrimaryKeyPlayerId.keyset()]){
            if(keyPlayInst.QS_Primary__c == true && opportunityIdVsNewPrimaryKeyPlayerId.containsKey(keyPlayInst.QS_Opportunity__c) && opportunityIdVsNewPrimaryKeyPlayerId.get(keyPlayInst.QS_Opportunity__c) != keyPlayInst.id){
                keyPlayInst.QS_Primary__c = false;
                toUpdate.add(keyPlayInst);
            }
        }
        if(!toUpdate.isEmpty()){
            update toUpdate;
        }
        
    }
    
    public void onAfterInsert(Map<Id,QS_Key_Players_Influencers__c> newKeyPlayersMap){

        //call the method to assign contact role
        assignContactRole(newKeyPlayersMap);
    }
    
     public void onBeforeUpdate(List<QS_Key_Players_Influencers__c> newKeyPlayers,Map<Id,QS_Key_Players_Influencers__c> oldKeyPlayersMap){
        
        List<QS_Key_Players_Influencers__c> filterKeyPlayers = new List<QS_Key_Players_Influencers__c>();
        
        for(QS_Key_Players_Influencers__c keyPlayer : newKeyPlayers){
            QS_Key_Players_Influencers__c oldKeyPlayer = oldKeyPlayersMap.get(keyPlayer.Id);
            
            // if old Name is not equal to Name and old Opportunity is not equal to Opportunity, check if it already exists.            
            if(!oldKeyPlayer.QS_Name__c.equals(keyPlayer.QS_Name__c)
                || !oldKeyPlayer.QS_Opportunity__c.equals(keyPlayer.QS_Opportunity__c)){
                filterKeyPlayers.add(keyPlayer);
            }
        }
        
        //check if Key Player with Contact, Opportunity already exist.
        checkAvailability(filterKeyPlayers);
    }
    
    public void onAfterUpdate(Map<Id,QS_Key_Players_Influencers__c> newKeyPlayersMap, Map<Id,QS_Key_Players_Influencers__c> oldKeyPlayersMap){
        
        Map<Id,QS_Key_Players_Influencers__c> filteredKeyPlayersMap = new Map<Id,QS_Key_Players_Influencers__c>();
        
        for(QS_Key_Players_Influencers__c keyPlayer : newKeyPlayersMap.values()){
            
            QS_Key_Players_Influencers__c oldKeyPlayer = oldKeyPlayersMap.get(keyPlayer.Id);
            
            // if old formal role is not equal to formal role, add the map to be reassign to contact role.            
            if(oldKeyPlayer.QS_Formal_Role__c != keyPlayer.QS_Formal_Role__c || oldKeyPlayer.QS_Primary__c!= keyPlayer.QS_Primary__c){
                system.debug('YES');
                filteredKeyPlayersMap.put(keyPlayer.Id,keyPlayer);
            }
        }
        system.debug('NO'+filteredKeyPlayersMap.values());
        //call the method to assign contact role
        assignContactRole(filteredKeyPlayersMap);
    }
    
    public void onBeforeDelete(List<QS_Key_Players_Influencers__c> oldKeyPlayers){
        
        // call the method to remove contact role.
        removeContactRole(oldKeyPlayers);
    }
    
    /**
    * @Author       Heidi Tang
    * @Date         2016-04-25
    * @Description  Check if key player already exist
    * @Requirement  REQ-0482 Auto-populate Contact Roles with Key Players/Influencers value.
    * @param Map<Id,Case> newKeyPlayersMap : map list of the new key players.       
    **/
    public void checkAvailability(List<QS_Key_Players_Influencers__c> newKeyPlayers){
        
        Set<Id> oppIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();

        for(QS_Key_Players_Influencers__c keyPlayer : newKeyPlayers){
            
            // Contact and Opportunity should not be empty.
            if(!String.isEmpty(keyPlayer.QS_Name__c) && !String.isEmpty(keyPlayer.QS_Opportunity__c)){

                //Store contact id and Opportunity in a set. 
                oppIds.add(keyPlayer.QS_Opportunity__c);
                contactIds.add(keyPlayer.QS_Name__c);
            }
        }
        
        // check if the key player already exists
        for(QS_Key_Players_Influencers__c existingKeyPlayer : new List<QS_Key_Players_Influencers__c>([
                                                            SELECT Id,QS_Name__c,QS_Opportunity__c FROM QS_Key_Players_Influencers__c 
                                                            WHERE QS_Name__c IN :contactIds AND QS_Opportunity__c IN :oppIds])){

            for(QS_Key_Players_Influencers__c newKeyPlayer : newKeyPlayers){
                if(newKeyPlayer.QS_Name__c.equals(existingKeyPlayer.QS_Name__c) &&
                    newKeyPlayer.QS_Opportunity__c.equals(existingKeyPlayer.QS_Opportunity__c)){
                    newKeyPlayer.addError(System.Label.Existing_Key_Player);
                }
            }
        }        
        
    }    
    
    /**
    * @Author       Heidi Tang
    * @Date         2016-04-25
    * @Description  Auto assigned of OpportunityContactRole by Key Players object.
    * @Requirement  REQ-0482 Auto-populate Contact Roles with Key Players/Influencers value.
    * @param Map<Id,Case> newKeyPlayersMap : map list of the new key players.       
    **/
    public void assignContactRole(Map<Id,QS_Key_Players_Influencers__c> newKeyPlayersMap){
        
        Set<Id> oppIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        List<OpportunityContactRole> oppContactRoleList = new List<OpportunityContactRole>();        
        List<OpportunityContactRole> newOppContactRoleList = new List<OpportunityContactRole>();        
        
        for(QS_Key_Players_Influencers__c keyPlayer : newKeyPlayersMap.values()){
            
            // Contact,Opportunity and Formal Role should not be empty.
            if(!String.isEmpty(keyPlayer.QS_Name__c) && !String.isEmpty(keyPlayer.QS_Opportunity__c) && !String.isEmpty(keyPlayer.QS_Formal_Role__c)){

                //Store contact id and Opportunity in a set. 
                oppIds.add(keyPlayer.QS_Opportunity__c);
                contactIds.add(keyPlayer.QS_Name__c);
                
                // create a new Opportunity Contact Role                
                newOppContactRoleList.add(createOpportunityContactRole(keyPlayer));
            }
        }
        
        // Get related Contact Roles
        oppContactRoleList = new List<OpportunityContactRole>([SELECT Id,ContactId,OpportunityId,Role FROM OpportunityContactRole
            WHERE OpportunityId IN :oppIds AND ContactId IN :contactIds]);
            
        // compare existing and new OpportunityContactRole
        for(Integer i=0;i<oppContactRoleList.size();i++){
            for(Integer j=0;j<newOppContactRoleList.size();j++){
                
                if(oppContactRoleList[i].ContactId.equals(newOppContactRoleList[j].ContactId) 
                    && oppContactRoleList[i].OpportunityId.equals(newOppContactRoleList[j].OpportunityId)){
                    
                    /** if new OpportunityContactRole Role is equal to existing, 
                    *   remove from the list to be upsert, 
                    *   else set the id to know that its for an update.
                    **/
                    //if(oppContactRoleList[i].Role != null){
                        //if(oppContactRoleList[i].equals(newOppContactRoleList[j])){
                            //newOppContactRoleList.remove(j);
                        //} else{
                            newOppContactRoleList[j].Id = oppContactRoleList[i].Id;
                       // }
                    //} else{
                        //newOppContactRoleList[j].Id = oppContactRoleList[i].Id;
                    //}
                }
            }
        }        
    
        if(newOppContactRoleList.size()>0){
            try{
                //insert or update the contact roles
                Database.upsert(newOppContactRoleList,false);
                //upsert newOppContactRoleList;
            } catch(DmlException dmle){
                // catch error on the dml statement
                for(QS_Key_Players_Influencers__c keyPlayer : newKeyPlayersMap.values()){
                    keyPlayer.addError(dmle.getDmlMessage(0));
                }
            }
        }
    }
    
    /**
    * @Author       Heidi Tang
    * @Date         2016-04-25
    * @Description  Create an OpportunityContactRole from a Key Player.
    * @Requirement  REQ-0482 Auto-populate Contact Roles with Key Players/Influencers value.
    * @param  QS_Key_Players_Influencers__c keyPlayer : the new key player.       
    **/
    public OpportunityContactRole createOpportunityContactRole(QS_Key_Players_Influencers__c keyPlayer){
        
        OpportunityContactRole oppContactRole = new OpportunityContactRole();
        oppContactRole.ContactId = keyPlayer.QS_Name__c;
        oppContactRole.OpportunityId = keyPlayer.QS_Opportunity__c;
        oppContactRole.Role = keyPlayer.QS_Formal_Role__c;
        oppContactRole.isPrimary = keyPlayer.QS_Primary__c;
        
        return oppContactRole;
    }
    
    /**
    * @Author       Heidi Tang
    * @Date         2016-04-25
    * @Description  Remove assignment of OpportunityContactRole by Key Players object.
    * @Requirement  REQ-0482 Auto-populate Contact Roles with Key Players/Influencers value.
    * @param Map<Id,Case> oldKeyPlayersMap : map list of the old key players.       
    **/
    public void removeContactRole(List<QS_Key_Players_Influencers__c> oldKeyPlayers){
        
        Set<Id> oppIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        Set<String> roleNames = new Set<String>();
        
        
        for(QS_Key_Players_Influencers__c keyPlayer : oldKeyPlayers){
            
            // Check if Related Contact, Opportunity and Role is not empty or null.
            if(!String.isEmpty(keyPlayer.QS_Name__c) && !String.isEmpty(keyPlayer.QS_Opportunity__c) && !String.isEmpty(keyPlayer.QS_Formal_Role__c)){
                oppIds.add(keyPlayer.QS_Opportunity__c);
                contactIds.add(keyPlayer.QS_Name__c);
                roleNames.add(keyPlayer.QS_Formal_Role__c);
                
            }
        }
        
        // Get related Contact Roles
        List<OpportunityContactRole> oppContactRoleList = new List<OpportunityContactRole>([SELECT Id FROM OpportunityContactRole
                                                                WHERE OpportunityId IN :oppIds AND ContactId IN :contactIds AND Role IN :roleNames]);
        
        if(oppContactRoleList.size()>0){
            try{
                //remove the contact roles
                delete oppContactRoleList;
            } catch(DmlException dmle){
                // catch error on the dml statement
                for(QS_Key_Players_Influencers__c keyPlayer : oldKeyPlayers){
                    keyPlayer.addError(dmle.getDmlMessage(0));
                }
            }
        }   
    }
}