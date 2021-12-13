# Model yaml description

- Ring represents system that communicates with other external or internal systems and brings value to the business.
- Delivery represents the minimal deployable unit of the system (ring). It means it can be deployed independently withing the other system deliveries if it doesn't break its contract.
- Block represents the minimal buildable artifact (e.g. library, set of scripts) which are deployed in the scope of the delivery. But it is an separate entity in the deployed application, like dll, file, folder and so on.


# Communication ELM - JS

Saving model by button sends it to Elm which will check it.
Changes in UI are sent to JS as events and allows to change values in view section
