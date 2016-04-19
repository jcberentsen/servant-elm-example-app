module NewBookForm.Types (..) where

import Material.Button as Button
import Material.Textfield as Textfield
import Material.Snackbar as Snackbar


type alias Model =
  { title : Maybe String
  , titleField : Textfield.Model
  , authorName : Maybe String
  , authorNameField : Textfield.Model
  , authorYearOfBirth : Maybe Int
  , authorYearOfBirthField : Textfield.Model
  , rating : Maybe Int
  , ratingField : Textfield.Model
  , submitButton : Button.Model
  , snackbar : Snackbar.Model ()
  }


type Action
  = CreateBook
  | FetchBooks
  | TitleFieldAction Textfield.Action
  | AuthorNameFieldAction Textfield.Action
  | AuthorYearOfBirthFieldAction Textfield.Action
  | RatingFieldAction Textfield.Action
  | SubmitButtonAction Button.Action
  | SnackbarAction (Snackbar.Action ())
