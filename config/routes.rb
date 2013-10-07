Reijiro::Application.routes.draw do
  resources :words, except: [:create, :show, :edit, :update, :destroy]
  resources :clips, only: [:index, :update, :destroy] do
    get :all, on: :collection
  end
  resources :levels, only: :index # TODO: levelはURLを再設計する ex. /levels/:level/words/:id/known
  get   '/levels/:level' => 'levels#show', as: 'level'
  post  '/levels/known/:id' => 'levels#known', as: 'known'

  get   '/search' => 'words#search', as: 'search' # TODO: /words/searchにしてindexで制御する
  post  '/alc(/:level)' => 'words#import_from_alc12000', as: 'alc'
  get   '/stats' => 'clips#stats', as: 'stats'
  get   '/next' => 'clips#nextup', as: 'next'
  post  '/import' => 'words#import', as: 'import'
  post  '/async_import/:word' => 'words#async_import'

  root 'clips#next'
end
