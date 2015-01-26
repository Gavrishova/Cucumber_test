module Selectors

  HOME = {
      buttons: {
          search: '.submit.button'
      },

      type_field: {
          place: 'place',
          dateFrom: '#dateCheckIn',
          dateTo: '#dateCheckOut'
      },
      sorting:{
          cheapest:'.filterelement[data-param="pr=0,50"]'
      },
      loading: '.overlay_msg',
      link_hotel: '.hotel_name_link.url',
      main_photo: '#photo_container',
      calendar_next: '.roll.right span'


  }
end