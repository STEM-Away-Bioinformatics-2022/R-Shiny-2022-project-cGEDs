library(shiny)
library(bs4Dash)
library(shinydashboard)
library(fresh)
library(psych)
library(DT)
library(vroom)
library(ggrepel)
library(ggExtra)
library(colourpicker)
library(shinyWidgets)
library(shinyjs)
library(slickR)
library(png)
library(ggplot2)
library(dplyr)
library(tidyr)
library(testthat)
library(shinytest)

plot1 <- "www/plots_combined.png"
plot2 <- "www/home_des.png"
hlogo <- "www/header_logo.png"

print(getwd())
print(list.files(getwd()))
dsGDSC1<-vroom::vroom("www/Drug-sensitivity-data-GDSC1.csv")
dsGDSC2<-vroom::vroom("www/Drug-sensitivity-data-GDSC2.csv")
ex<-vroom::vroom("www/Gene-expression-data-GDSC.csv ")# Gene Expression 

ui <- bs4DashPage(
  freshTheme = create_theme(
    bs4dash_vars(
      navbar_light_color = "#669090" 
    ),
    bs4dash_yiq(
      contrasted_threshold = 10,
      text_dark = "#FFFF82"
    ),
    bs4dash_layout(
      main_bg = "#ffe5d0" 
    ),
    bs4dash_sidebar_light(
      bg = "#005959", 
      color = "#fff1d0", 
      hover_color = "#ffffff" 
    ),
    bs4dash_status(
      primary = "#669090", 
      danger = "#ffffff", light = "#ffffff", warning = "#008080",
      success = "#aacc00"    
    ),
    bs4dash_color(
      gray_900 = "#0F0326", 
      white = "#c3ad97" 
      
    )
  ),
  title = bs4DashBrand(title = "cGEDs", 
                       color = 'success', 
                       opacity = 1, 
                       href = "https://stemaway.com/"),
  header = bs4DashNavbar(
    title = NULL,
    div(style = "margin-left:auto;margin-right:auto; text-align:center; color:#001219",
        HTML('<h4>cGEDs: Cancer Gene-Expression & Drug-Sensitivity App')
    ),
    fixed = FALSE,
    border = TRUE
  ),
  sidebar <- bs4DashSidebar(
    sidebarUserPanel(div(style = "margin-left:auto;margin-right:auto; text-align:center; color:#C8F8E5",
                         HTML('cGEDs'))
                     ),
    hr(),
    bs4SidebarMenu(
      id = "tabs",
      bs4SidebarMenuItem("Home Page", tabName = "introduction",icon = icon("home")),
      bs4SidebarMenuItem(text=tags$div("Data Selelection &",tags$br(), "Correlation Calculation",
                                       style= "display: inline-block;vertical-align:middle"),
                         tabName = "dataSelection",icon = icon('mouse-pointer')),
      bs4SidebarMenuItem("Apply thresholds", tabName = "applyThresholds",icon=icon('sliders-h')),
      bs4SidebarMenuItem("Scatter/Boxplot", tabName = "scatterBoxplot",icon = icon('chart-line')),
      bs4SidebarMenuItem("Tutorial", tabName = "tutorial",icon = icon('file-video')),
      bs4SidebarMenuItem("FAQs", icon = icon("question-circle"), tabName = "faq"),
      bs4SidebarMenuItem("Contact", tabName = "contact", icon = icon("users")),
      bs4SidebarMenuItem("Meet Our Team", tabName = "meetteam")
    ),
    disable = FALSE,
    skin = 'light',
    collapsed = FALSE,
    minified = TRUE,
    expandOnHover = TRUE,
    fixed = FALSE,

  ),
  body <- bs4DashBody(
    skin = 'light',
    bs4TabItems(
      # Home page content
      bs4TabItem(tabName = "introduction",
                 fluidRow(
                   column(12,
                          align="center",
                          #Introduction block 
                          bs4Jumbotron(height = 100, width = "85%",
                                       status = "warning",btnName = NULL,
                                       title = "cGEDs - Cancer Gene-Expression Drug-Sensitivity App",
                                       lead = "An application for finding drug effectivity biomarkers in different cancer types",
                                       href = "https://stemaway.com/",
                                       div(style ="display:inline-block", 
                                           actionBttn('to_dataSelection',
                                                      label = 'Begin',
                                                      style = "gradient",
                                                      color = "success",
                                                      size = "md",
                                                      block = FALSE,
                                                      no_outline = TRUE),
                                           actionBttn('to_tutorial', label = 'Tutorial',style = "gradient",
                                                      color = "success",
                                                      size = "md",
                                                      block = FALSE,
                                                      no_outline = TRUE),
                                           actionBttn('to_faq', label = 'FAQ', style = "gradient",
                                                      color = "success",
                                                      size = "md",
                                                      block = FALSE,
                                                      no_outline = TRUE)
                                       )
                          ),
                          hr(),
                          hr(),
                          slickR(obj = c(hlogo,plot1,plot2) ,height = 450, width = "96%") +
                            settings(dots = TRUE, autoplay = TRUE, autoplaySpeed = 2000),
                          hr()
                          )
                   )
                 ),
      bs4TabItem(tabName = "dataSelection",
                 fluidPage(
                   column(12,
                          div(style = "display:inline-block; float:left",
                              actionBttn('backto_introduction', label = 'Back', 
                                         style = "gradient",
                                         color = "success",
                                         size = "md",
                                         block = FALSE,
                                         no_outline = TRUE)),
                          div(style = "display:inline-block; float:right",
                              actionBttn('to_thresh', label = 'Next', 
                                         style = "gradient",
                                         color = "success",
                                         size = "md",
                                         block = FALSE,
                                         no_outline = TRUE))
                          ),
                   column(12, align="center",
                          HTML("<h5>Choose from the options given to begin</h5>")
                          ),
                   hr()
                   ),          
                 fluidRow(
                   column(4,align="center",offset = 1,
                          span(
                            div(style = "display:inline-block;",(selectInput("dataset","Select a drug sensitivity and gene expression dataset",
                                                                             choices=c("GDSC1","GDSC2"),selected=NULL))
                            ),
                            div(style = "display:inline-block; ",
                                dropMenu(
                                  circleButton("Info",status = "warning",size = "xs", icon = icon('info')),
                                  h6(strong('You can choose the drug sensitivity and gene expression dataset among these publicly available datasets:')),
                                  br(),
                                  h6('GDSC1: 970 Cell lines and 403 Compounds'),
                                  h6('GDSC2: 969 Cell lines and 297 Compounds'),
                                  placement = "right",
                                  arrow = TRUE)
                            )
                          ),
                          selectInput("cancer","Select a cancer type",
                                      choices=c("Brain lower grade glioma (LGG)",
                                                "Kidney renal clear cell carcinoma (KIRC)",
                                                "Esophageal carcinoma (ESCA)",
                                                "Breast invasive carcinoma (BRCA)",
                                                "Stomach adenocarcinoma (STAD)","Mesothelioma (MESO)",
                                                "Skin cutaneous melanoma (SKCM)","Lung adenocarcinoma (LUAD)",
                                                "Glioblastoma multiforme (GBM)",
                                                "Head and neck squamous cell carcinoma(HNSC)",
                                                "Liver hepatocellular carcinoma (LIHC)",
                                                "Small cell lung cancer (SCLC)","Neuroblastoma (NB)",
                                                "Ovarian serous cystadenocarcinoma (OV)",
                                                "Colon and rectum adenocarcinoa (COAD/READ) (COREAD)",
                                                "Multiple myeloma (MM)",
                                                "Lung squamous cell carcinoma (LUSC)",
                                                "Uterine corpus endometrial carcinoma (UCEC)",
                                                "Pancreatic adenocarcinoma (PAAD)",
                                                "Acute lymphoblastic leukemia (ALL)",
                                                "Head and neck squamous cell carcinoma (HNSC)",
                                                "Lymphoid neoplasm diffuse large B-cell lymphoma (DLBC)",
                                                "Medulloblastoma (MB)","Chronic myelogenous leukemia (LCML)",
                                                "Thyroid carcinoma (THCA)",
                                                "Bladder urothelial carcinoma (BLCA)","Prostate adenocarcinoma (PRAD)",
                                                "Adrenocortical carcinoma (ACC)"," Chronic lymphocytic leukemia (CLL)",
                                                "Cervical squamous cell carcinoma and endocervical adenocarcinoma (CESC)",
                                                "Acute myeloid leukemia (LAML)"),selected=NULL),
                          selectizeInput("Genes", "Please enter your desiered genes",
                                         choices = colnames(ex[,3:54]),multiple=TRUE),

                          useSweetAlert(),
                          actionBttn("cal","Calculate Correlations", 
                                     style = "gradient",
                                     color = "success",
                                     size = "md",
                                     block = FALSE,
                                     no_outline = TRUE)
                          ),
                   column(5,align="center",offset = 1,wellPanel(
                     DT::DTOutput("cortabs"),
                     br(),
                     uiOutput("download")
                     #uiOutput("threshtab")
                     )
                     )
                   ),
                 fluidRow(
                   column(12,
                          hr()
                          )
                   ),
                 fluidRow(
                   column(12,align="center",
                          )
                   )   
                 ),
    bs4TabItem(tabName = "applyThresholds",
               fluidPage(
                 column(12,
                        div(style = "display:inline-block; float:left",
                            actionBttn('backto_dataSelection', label = 'Back', 
                                       style = "gradient",
                                       color = "success",
                                       size = "md",
                                       block = FALSE,
                                       no_outline = TRUE)),
                        div(style = "display:inline-block; float:right",
                            actionBttn('to_bbplot', label = 'Next',style = "gradient",
                                       color = "success",
                                       size = "md",
                                       block = FALSE,
                                       no_outline = TRUE))
                 ),
                 column(12, align="center",
                        HTML("<h5>Apply thresholds to select the most associated Gene-Drug pairs for the visualization</h5>")
                 ),
                 hr(),
               ),      
               fluidRow(
                 column(4,align="center",offset = 1,
                        numericInput("FDRThr","Choose Gene-drug pairs with FDRs less than:", value = 0.05),
                        wellPanel(
                          chooseSliderSkin(skin = 'Modern'),
                          sliderInput("PosCorThre", "Choose Gene-drug pairs with correlations more than:",min = 0, max =1,value = 0.7,step = 0.1),
                          sliderInput("NegCorThre", "Choose Gene-drug pairs with correlations less than:",min = -1, max =0,value = -0.7,step = 0.1),
                          br(),
                          actionBttn("Thre","Apply Thresholds",
                                     style="gradient",
                                     color="success",size = "md"))),
                 column(5,align="center",offset = 1,
                        wellPanel(DT::DTOutput("Sigcors")),
                        br(),
                        uiOutput("downloadthre")
                 )
               ),
               fluidRow(
                 column(12,
                        hr()
                 )
               ),
               fluidPage(
                 column(12,align="center",
                        br(),
                        div(style ="display:inline-block", 
                            uiOutput('to_scatterPlot')),
                        div(style ="display:inline-block", 
                            uiOutput('to_bubblePlot'))
                 )
                 
               )
            
    ), 

    bs4TabItem(tabName = "scatterBoxplot",
          fluidRow(
            column(12,
                   div(style = "display:inline-block; float:left",
                       actionBttn('backto_bbplot', label = 'Back', 
                                  style = "gradient",
                                  color = "success",
                                  size = "md",
                                  block = FALSE,
                                  no_outline = TRUE))
            ),
            column(12, align="center",
                   HTML("<h5>Select among the most associated gene-drug pairs to be visualized by a scatter plot with a marginal boxplot </h5>")
            )
          ),
          hr(),
          fluidRow(
            column(6,align="center",
                   br(),
                   uiOutput("selGenedrug"),
                   br(),
                   br(),
                   uiOutput("scatterLabel"),
                   uiOutput("ShowBoxplot"),
                   div(id = "Col0"),
                   div(id = "Col1"),
                   div(id = "Col2")
            ),
            column(4,align="center",
                   br(),
                   br(),
                   plotOutput("scatterplt",width = "100%"),
                   br(),
                   br(),
                   br(),
                   br(),
                   br(),
                   br(),
                   br(),
                   br(),
                   br(),
                   uiOutput("scatterdownload", label = "Download")
            )
          ),
          fluidRow(column(12,align="center",
                   #uiOutput('downloadScatter')
                   hr()
                   )      
          )
          
    ),

    bs4TabItem(tabName = "tutorial",
          fluidRow(
            column(4,
                   box('This is the tutorial page', title = "tutorial",  
                       status = "primary", solidHeader = TRUE,
                       collapsed = FALSE, width=12)                    
            )
          )
  ),
  bs4TabItem(tabName = "faq",
          fluidRow(
            column(4,
                   box('Questions here', title = "FAQ Page",  
                       status = "primary", solidHeader = TRUE, collapsible = T,
                       collapsed = FALSE, width=12)                    
            )
          )
  ),
  bs4TabItem(tabName = "contact",
          fluidRow(
            column(4,
                   box('contact', title = "Contact us",  
                       status = "primary", solidHeader = TRUE, collapsible = T,
                       collapsed = FALSE, width=12)                    
            )
          )
  ),
  bs4TabItem(tabName = "meetteam",
          fluidRow(
            column(4,
                   box('content goes here', title = "The team",  
                       status = "primary", solidHeader = TRUE, collapsible = T,
                       collapsed = FALSE, width=12)                    
            )
          )
       )

    )
  ),
  controlbar = NULL,
  skin = 'light',
  footer = bs4DashFooter(
    left = HTML("<a href='https://github.com/STEM-Away-RShiny-app-project/cGEDs' style = 'color:#FFFFFF'>@BI-STEM-Away</a>"),
    right = HTML("<a href='https://github.com/STEM-Away-RShiny-app-project/cGEDs' style = 'color:#FFFFFF'>This app is created by STEM-Away RShiny Project Team - 2022</a>"),
    fixed = FALSE),
  preloader = NULL,
  options = NULL,
  fullscreen = FALSE,
  help = FALSE,
  dark = FALSE,
  scrollToTop = TRUE
)



server <- function(input, output,session) {
  
  # Home page buttons
  observeEvent(input$to_dataSelection, {
    updateTabItems(session, "tabs", selected = "dataSelection")
  }
  )
  observeEvent(input$to_tutorial, {
    updateTabItems(session, "tabs", selected ="tutorial")
  }
  )
  
  observeEvent(input$to_faq, {
    updateTabItems(session, "tabs", selected ="faq")
  }
  )
  
  # Data Selection & Correlation Calculation Buttons

  observeEvent(input$backto_introduction, {
    updateTabItems(session, "tabs", "introduction")
  }
  )
  observeEvent(input$to_thresh, {
    updateTabItems(session, "tabs", "applyThresholds")
  }
  )

  
  #Apply Thresholds button
  observeEvent(input$backto_dataSelection, {
    updateTabItems(session, "tabs", "dataSelection")
  }
  )
  observeEvent(input$to_bbplot, {
    updateTabItems(session, "tabs", "bubblePlot")
  }
  )
  observeEvent(input$to_bubblePlot, {
    updateTabItems(session, "tabs", "bubblePlot")
  }
  )
  
  observeEvent(input$to_scatterPlot, {
    updateTabItems(session, "tabs", "scatterBoxplot")
  }
  )  

  
  observeEvent(input$to_selectData, {
    updateTabItems(session, "tabs", "dataSelection")
  }
  )  
  
  # Apply thresholds & Scatter-boxplot buttons
  observeEvent(input$backto_bbplot, {
    updateTabItems(session, "tabs", "bubblePlot")
  }
  )
  
  # Dataset and cancer type selection by the user
  dataselect<-reactive({
    if (input$dataset=="GDSC1"){
      ds <- dsGDSC1 %>% 
        filter(dsGDSC1$`Cancer-Type`== input$cancer)
    }
    else if(input$dataset=="GDSC2"){
      ds<-dsGDSC2 %>% 
        filter(dsGDSC2$`Cancer-Type`== input$cancer)
    } 
    
  })
  
  # remove the cancer type column since it's not necessary anymore
  ds2<-reactive(dataselect()[-4])
  
  # Gene selection by the user
  ex2<-reactive(ex[,input$Genes])
  
  # Add Cell line column to ex2 needed for merging step
  ex3 <- reactive(cbind('Cell line' =ex[1], ex2()))
  
  # Merge the two tables
  df <- reactive(merge(x = ds2(), y = ex3(), by ="Cell line"))
  correlations<-eventReactive(input$cal,{
    
    # Provide a vector of drug names
    # Remove drugs with less than two cell lines
    drugs <- df() %>%
      select(Drug.name, 'Cell line') %>%
      group_by(Drug.name) %>%
      summarise(Num_cell_lines=n()) %>%
      filter(Num_cell_lines > 2)
    
    drugs <- unique(df()$Drug.name)
    corrs <- NULL
    
    # Progress bar code
    progressSweetAlert(
      session = session, id = "myprogress",
      title = "Work in progress",
      display_pct = TRUE, value = 0
    )
    # Calculate the correlations and FDRs for each drug separately
    
    for (i in 1:length(drugs)) {
      
      #Filter the rows related to each drug 
      drug_df <- df() %>%
        filter(Drug.name == drugs[i])
      
      #drug_df[,5:ncol(drug_df) refers to gene expression data and drug_df[,3]
      #refers to IC50 column  
      drug_corr <- suppressWarnings(corr.test(drug_df[,5:length(drug_df)], drug_df[,3]
                                              , method = "pearson",adjust="fdr"))
      
      new_entry <- data.frame(Corr=drug_corr$r, FDR=drug_corr$p.adj) %>%
        mutate(Drug=drugs[i])
      new_entry$Gene <- row.names(new_entry)
      row.names(new_entry) <- NULL
      corrs <- rbind(corrs, new_entry)
    }
    for (i in seq_len(50)) {
      Sys.sleep(0.1)
      updateProgressBar(
        session = session,
        id = "myprogress",
        value = i*2)
    }
    closeSweetAlert(session = session)
    sendSweetAlert(
      session = session,
      title =" Correlation Calculation completed !",
      type = "success"
    )
    return(corrs)
  })
  
  # Add the ability to download the correlation table
  # Download button appears after clicking on the calculate button using observeEvent and renderUI
  observeEvent(input$cal, {
    output$download <- renderUI({ 
      downloadHandler(
        filename = function() {
          "Pearson Correlations and FDRs.tsv"
        },
        content = function(file) {
          vroom::vroom_write(correlations(), file)
        }
        
      ) 
    }) 
  })
  
  # "Next" button appears when clicking on the "Correlation Calculation" button
  observeEvent(input$cal, {output$to_next<-renderUI({actionBttn("to_next","Next",style="gradient",color ="success")})
  })
  
  # "Bubble Plot" and "Scatter/Boxplot" buttons appear when clicking on the "Apply Thresholds" button 
  observeEvent(input$Thre, {output$to_scatterPlot<-renderUI({actionBttn("to_scatterPlot","Scatter-Boxplot",style="gradient",color ="success")})
  })
  
  #Apply thresholds
  sigcors<-eventReactive(input$Thre,{
    sigcors1<-subset(correlations(), FDR< input$FDRThr & Corr> min(input$PosCorThre))
    sigcors2<-subset(correlations(), FDR< input$FDRThr & Corr< max(input$NegCorThre))
    sigcors<-(rbind(sigcors1,sigcors2))
  })
  
  # Download button appears after clicking on the apply threshold button using observeEvent and renderUI
  observeEvent(input$Thre, {
    output$downloadthre <- renderUI({ 
      downloadHandler(
        filename = function() {
          "Gene/Drug pairs passing the thresholds.tsv"
        },
        content = function(file) {
          vroom::vroom_write(correlations(), file)
        }
        
      ) 
    }) 
  })
  
  #Provide Gene/Drug pair list for the Drop-down of choosing Gene/Drug pair for the visualization
  sigcors4<-reactive({
    GeneDrug <-paste(sigcors()$Gene ," / ", sigcors()$Drug)
    sigcors3<-cbind(sigcors(),GeneDrug)
  })
  
  #Drop-down for choosing Gene/Drug pair for the visualization
  observeEvent(input$Thre,{output$selGenedrug<-renderUI({
    selectInput("selGenedrug", "Please choose desiered Gene/Drug pair for the visualization",
                choices = c("",sigcors4()$GeneDrug),multiple=FALSE,selected=NULL)
  }) })
  #Scatter label check box appears after selGenedrug drop-down works
  observeEvent(req(input$selGenedrug),{output$scatterLabel<-renderUI({

  prettyCheckbox("scatterLabel","Show cell line names",value = TRUE
                    ,status = "success", outline = TRUE)
   }) })
   # Show box plot check box appears after selGenedrug drop-down works 
   observeEvent(req(input$selGenedrug),{output$ShowBoxplot<-renderUI({
   prettyCheckbox("ShowBoxplot","Show marginal boxplots",value = TRUE,
                    status = "success", outline = TRUE)
   }) })

  #Scatter-boxplot
   
   Scatter<-reactive({
     req(input$selGenedrug)
     drug<-sigcors4()[which(sigcors4()$GeneDrug ==input$selGenedrug) , 3]
     drug_df <- subset(df(), Drug.name == drug)
     gene<-as.character(sigcors4()[which(sigcors4()$GeneDrug ==input$selGenedrug), 4])
     med=median(drug_df[,gene])
     drug_df$GeneExpressLevel = ifelse (drug_df[,gene] >= med, "high", "low")

    
    if(input$ShowBoxplot==TRUE){
      if(input$scatterLabel==TRUE){
        x<-ggplot(drug_df,aes(drug_df[,gene],IC50,label=`Cell line`))+
          theme_bw()+theme(text = element_text(size=12), legend.position='bottom')+
          geom_smooth(method=("lm"))+
          labs( x = paste("Expression levels of",gene),y= paste("IC50 of",drug))+
          geom_point(size=2, aes(colour=GeneExpressLevel))+
          scale_colour_manual(values=c(input$col1, input$col2))+
          geom_text_repel()
        ggMarginal(x,type="boxplot",groupColour=TRUE,groupFill = TRUE)
      }
      else{
        x<-ggplot(drug_df,aes(drug_df[,gene],IC50,label=`Cell line`))+
          theme_bw()+theme(text = element_text(size=12), legend.position='bottom')+
          geom_smooth(method=("lm"))+
          labs( x = paste("Expression levels of",gene),y= paste("IC50 of",drug))+
          geom_point(size=2, aes(colour=GeneExpressLevel))+
          scale_colour_manual(values=c(input$col1,input$col2))
        ggMarginal(x,type="boxplot",groupColour=TRUE,groupFill = TRUE)
      }
    }
    else{
      if(input$scatterLabel==FALSE){
        ggplot(drug_df,aes(drug_df[,gene],IC50,label=`Cell line`))+
          theme_bw()+theme(text = element_text(size=12), legend.position='bottom')+
          geom_smooth(method=("lm"))+
          labs( x = paste("Expression levels of",gene),y= paste("IC50 of",drug))+
          geom_point(size=1)
      }
      else{
        ggplot(drug_df,aes(drug_df[,gene],IC50,label=`Cell line`))+
          theme_bw()+theme(text = element_text(size=12), legend.position='bottom')+
          geom_smooth(method=("lm"))+
          labs( x = paste("Expression levels of",gene),y= paste("IC50 of",drug))+
          geom_point(size=1)+geom_text_repel()

         }
     }
   })
   
   # ObserveEvent functions related to selecting the color of scatter-boxplots
   observeEvent(input$ShowBoxplot,{
     if (input$ShowBoxplot==TRUE){
       insertUI(
         selector = "#Col1",
         ui=colourpicker::colourInput("col1", "Select colour of boxplots related to the high expression cell lines"
       ,showColour="both", value = "#009688")
       )
     }
     else if(input$ShowBoxplot==FALSE){
       removeUI(
         selector = "div#Col1 > div"
       )
     } 
   })
  
   observeEvent(input$ShowBoxplot,{
     if (input$ShowBoxplot==TRUE){
       insertUI(
         selector = "#Col2",
         ui=colourpicker::colourInput("col2", "Select colour of boxplots related to the low expression cell lines"
         ,showColour="both", value = "F78A25")
       )
     }
     else if(input$ShowBoxplot==FALSE){
       removeUI(
         selector = "div#Col2 > div"
       )
     } 
   })
  
   observeEvent(input$ShowBoxplot,{
     if (input$ShowBoxplot==FALSE){
       insertUI(
         selector = "#Col0",
         ui=colourpicker::colourInput("col0", "Select colour of dots"
         ,showColour="both", value = "F78A25")
       )
     }
     else if(input$ShowBoxplot==TRUE){
       removeUI(
         selector = "div#Col0 > div"
       )
     } 
   })
   
   # The bubble plot appears after clicking on plot bubble plot button
   bubbleButton<-eventReactive(input$plotBubbleplot, {
     Bubbleplot()
   })
   
   
   output$bubble <-renderPlot(
   bubbleButton(),res = 96, height =function(){length(unique(sigcors()$Gene))*15+450} , width = function(){length(unique(sigcors()$Drug))*35+300}
   )
   
   
   observeEvent(input$plotBubbleplot, {
     # The download button of the scatter plot 
     output$bubbledownload <-renderUI({ downloadHandler(
       filename =  function() {
         "Bubble Plot.png"
       },
       # content is a function with argument file. content writes the plot to the device
       content = function(file) {
         device <- function(..., width, height) {
           grDevices::png(..., width = width, height = height,
                          res = 300, units = "in")}
         ggsave(file, plot = Bubbleplot(), device = device)
       } 
     )
     })
   })
   
   output$scatterplt<-renderPlot(Scatter(),res = 96, height = 600, width = 600)
   
   # The download button of the scatter plot spears after selGenedrug drop-down works
   observeEvent(req(input$selGenedrug), {
     # The download button of the scatter plot 
     output$scatterdownload <-renderUI({ downloadHandler(
     filename =  function() {
       "Scatter Plot.png"
     },
     # content is a function with argument file. content writes the plot to the device
     content = function(file) {
       device <- function(..., width, height) {
         grDevices::png(..., width = width, height = height,
                        res = 300, units = "in")}
       ggsave(file, plot = Scatter(), device = device)
     } 
   )
   })
   })
   
   output$cortabs<-DT::renderDT(
     correlations()

  )
  output$Sigcors<-DT::renderDT(
    sigcors()
  )
  
  #output$scatterplt<-renderPlot(
  #  Scatter(),res = 96, height = 600, width = 600,
  #ggsave("plot.pdf",Scatter()) 
  # )
  
  
}

shinyApp(ui = ui, server = server)


