library(shiny)
library(ggplot2)
library(dplyr)
library(geosphere)
library(httr)
library(rjson)


ui <- fluidPage(
    titlePanel("Chicago Area Food"),
    sidebarLayout(
        sidebarPanel(
            textInput("addressInput", "Address", ""),
            sliderInput("milesInput", "Distance From My Address", 0, 35, c(0, 5), post = " Miles"),
            checkboxGroupInput("facilityType", "Type of Establishment",
                               choices = c("Restaurant", "Bar", "Bakery", "Banquet", "Ice Cream", "Pantry", "Paleteria"),
                               selected = "Restaurant"),
            checkboxGroupInput("riskInput", "Risk Level",
                               choices = c("Risk 3 (Low)", "Risk 2 (Medium)", "Risk 1 (High)"),
                               selected = "Risk 3 (Low)"),
            checkboxGroupInput("resultInput", "Result", choices = c("Pass", "Fail"), selected = "Pass")
            #ADD RADIO BUTTONS
            
        ),
        mainPanel(
            plotOutput("newplot"),
            br(), br(),
            tableOutput("results")
        )
    )
)

server <- function(input, output) {
    
    
    filtered <- reactive({
        if (is.null(input$facilityType)) {
            return(NULL)
        }
        data <- paste0("[",paste(paste0("\"",input$addressInput,"\""),collapse=","),"]")
        url  <- "http://www.datasciencetoolkit.org/street2coordinates"
        response <- POST(url,body=data)
        json     <- fromJSON(content(response,type="text"))
        location <- c(json[[1]][[2]], json[[1]][[4]])
        
        Distance <- NULL
        for (i in 1:(nrow(Food) - 1)){
            Distance <- distm(x = c(json[[1]][[4]], json[[1]][[2]]),
                          y = c(Food$Longitude[i], Food$Latitude[i]),
                          fun = distHaversine) / 1609
            
            Food$Distance[i] <- c(Distance)
                          
        }
        
        
        
        Food %>%
            filter(Distance >= input$milesInput[1],
                   Distance <= input$milesInput[2],
                   Risk == input$riskInput,
                   `Facility Type` == input$facilityType
            )
        
        
        
        
        
        
    })
    
    
    
    output$newplot <- renderPlot({
        ggplot(filtered()) +
            geom_point(mapping = aes(x = filtered()$Longitude, y = filtered()$Latitude, color = factor(filtered()$Results))) +
            labs(color = "Conditions") + 
            xlab("Longitude") + ylab("Latitude") + 
            ggtitle("Restaurants Near Me")
        
    })
    
    output$results <- renderTable({
        filtered()
    })
}

shinyApp(ui = ui, server = server)

