#========================================================================
# Author 	: Kevin RAHETILAHY                                          #
#========================================================================

##############################################################
#                      LOAD ASSEMBLY                         #
##############################################################

[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')  				| out-null
[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') 				| out-null
[System.Reflection.Assembly]::LoadWithPartialName('PresentationCore')      				| out-null
[System.Reflection.Assembly]::LoadFrom('assembly\MahApps.Metro.dll')       				| out-null
[System.Reflection.Assembly]::LoadFrom('assembly\System.Windows.Interactivity.dll') 	| out-null
[System.Windows.Forms.Application]::EnableVisualStyles()

##############################################################
#                      LOAD FUNCTION                         #
##############################################################
                      
function LoadXml ($Global:filename)
{
    $XamlLoader=(New-Object System.Xml.XmlDocument)
    $XamlLoader.Load($filename)
    return $XamlLoader
}

# Load MainWindow
$XamlMainWindow=LoadXml(".\Main.xaml")
$Reader=(New-Object System.Xml.XmlNodeReader $XamlMainWindow)
$Form=[Windows.Markup.XamlReader]::Load($Reader)

##############################################################
#              INCLUDE EXTERNAL SCRIPT                       #
##############################################################
$pathPanel= split-path -parent $MyInvocation.MyCommand.Definition
."$pathPanel\scripts\TrainScript.ps1"    
."$pathPanel\scripts\UIControl.ps1"  
                        
##############################################################
#                CONTROL INITIALIZATION                      #
##############################################################

# === Inside main xaml ===
$gridTrain       = $Form.FindName("trainGrid")
$datagridTrain   = $Form.FindName("datagridTrain")

# ===  Window Resources   ==== 
# $ApplicationResources = $Form.Resources.MergedDictionaries


##############################################################
#                DATAS EXAMPLE                               #
##############################################################

 
$rawResultTrains = (Get-gare -gare "La defense").idgare | Get-TrainDirection | %{ Get-NextTrain -idgare $_.idgare -traindirection $_.direction } 
# remove empty values
$script:allTrains = $rawResultTrains |?{$_}
# Add datas to the datagrid
$datagridTrain.ItemsSource = $allTrains

##############################################################
#                FUNCTIONS                                   #
##############################################################



##############################################################
#                MANAGE EVENT ON PANEL                       #
##############################################################


function Search_train(){
    
       foreach ($train in $allTrains ){       
       
            if ($train){      
                
                $trainIndex = $allTrains.IndexOf($train)

                # We assign a Name for the stackpanel for a train
                $PanelIndexName  = [String]("StackPparent_"+$trainIndex ) 
                $OneTrainStackPanel = New-StackPanel -Name $PanelIndexName -Margin "0,4,0,4" -Orientation "Horizontal" -HorizontalAlignment "Stretch" -Background "#5B965B"
               
                # ============== The stackPanel containing infos about the train ... ==================
                $StackPanelInfos  = New-StackPanel  -Margin "20,5,0,2" -Orientation "Vertical" 
                
                # Direction and time reamining 
                $directionTextBlock = New-TextBlock  -Margin "0,0,0,0" -ForeGround "White"   
                $TimeTextBlock      = New-TextBlock  -Margin "0,0,0,0" -ForeGround "White"
                $directionTextBlock.Text = "Direction: "+ [String]$train.direction 
                $TimeTextBlock.Text      = "Time: " + $train.ETAinMin 
                
                # append textBlocks to the Informations StackPanel
                $StackPanelInfos.Children.Add($directionTextBlock) | out-Null
                $StackPanelInfos.Children.Add($TimeTextBlock)      | out-Null
                
                # ============ The Train Icon XD ======================================================
                

                # Merge everything to the Train stackPanel
                $OneTrainStackPanel.Children.Add($StackPanelInfos) | out-Null
                
                # append the current train to the main Grid. 
                $gridTrain.Children.Add($OneTrainStackPanel) | out-Null
            }
       }  
   }
   


##############################################################
#                SHOW WINDOW                                 #
##############################################################

Search_train

$Form.ShowDialog() | Out-Null

