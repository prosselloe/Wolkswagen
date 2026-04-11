# Blueprint: VW Classics App

## Overview

This is a Flutter application that serves as a digital encyclopedia for classic Volkswagen models. It allows users to browse a collection of iconic VW cars, view detailed information about each model, and learn about their history and technical specifications.

## Features

* **Model Catalog:** A comprehensive list of classic Volkswagen models, including their names, production years, and images.
* **Detailed Model Information:** Each model has a dedicated screen with detailed information, including technical specifications, production numbers, and historical context.
* **Search and Filter:** Users can search for specific models and filter the catalog by manufacturing plant.
* **Sort:** The list of models can be sorted by name, production year, or number of units produced.
* **Multi-language Support:** The application is available in multiple languages, including English, Spanish, French, Portuguese, and Catalan.

## Changes

### Multi-language Descriptions

* Updated the `VWModel` class to include separate fields for descriptions in English, Spanish, French, Portuguese, and Catalan (`description_en`, `description_es`, `description_fr`, `description_pt`, `description_ca`).
* Modified the `DetailScreen` to dynamically display the description in the user's selected language.
* Updated the `assets/data/db_*.json` files to include the new description fields for each model and language.

## Next Steps

* **Image Gallery:** Add a gallery of images for each model.
* **Video Content:** Include videos of the models (e.g., reviews, historical footage).
* **User Accounts:** Allow users to create accounts to save their favorite models and add notes.
